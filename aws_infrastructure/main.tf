terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-1"
}

resource "random_id" "enclave_bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "enclave_bucket" {
  bucket = "enclave-bucket-${random_id.enclave_bucket_id.hex}"
}

resource "aws_s3_bucket_ownership_controls" "enclave_bucket_ownership_controls" {
  bucket = aws_s3_bucket.enclave_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "enclave_bucket_public_access_block" {
  bucket = aws_s3_bucket.enclave_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "enclave_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.enclave_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.enclave_bucket_public_access_block,
  ]

  bucket = aws_s3_bucket.enclave_bucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "enclave_parent_zip" {
  bucket = aws_s3_bucket.enclave_bucket.id
  key    = "enclave_parent.zip"
  source = "../enclave_parent.zip"
}

resource "aws_kms_key" "enclave_kms_key" {
  tags = {
    Name = "enclave-kms-key"
  }
}

resource "aws_vpc" "enclave_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "enclave-vpc"
  }
}

resource "aws_internet_gateway" "enclave_igw" {
  vpc_id = aws_vpc.enclave_vpc.id

  tags = {
    Name = "enclave-igw"
  }
}

resource "aws_subnet" "enclave_subnet" {
  vpc_id                  = aws_vpc.enclave_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "enclave-subnet"
  }
}

resource "aws_route_table" "enclave_rtb" {
  vpc_id = aws_vpc.enclave_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.enclave_igw.id
  }

  tags = {
    Name = "enclave-rtb"
  }
}

resource "aws_route_table_association" "enclave_rtb_association" {
  subnet_id      = aws_subnet.enclave_subnet.id
  route_table_id = aws_route_table.enclave_rtb.id
}

resource "aws_security_group" "enclave_security_group" {
  name = "enclave-security-group"

  vpc_id = aws_vpc.enclave_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "enclave-security-group"
  }
}

resource "aws_network_interface" "enclave_network_interface" {
  subnet_id       = aws_subnet.enclave_subnet.id
  security_groups = [aws_security_group.enclave_security_group.id]

  tags = {
    Name = "enclave-network-interface"
  }
}

resource "aws_iam_role" "enclave_role" {
  name = "enclave-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "encalve_role_s3_policy_attachment" {
  role = aws_iam_role.enclave_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "enclave_instance_profile" {
  name = "enclave-instance-profile"
  role = aws_iam_role.enclave_role.name
}

resource "aws_instance" "enclave_instance" {
  depends_on = [aws_s3_object.enclave_parent_zip]

  ami           = "ami-07619059e86eaaaa2" # Amazon Linux 2023 AMI
  instance_type = "m5.2xlarge"

  iam_instance_profile = aws_iam_instance_profile.enclave_instance_profile.name

  enclave_options {
    enabled = true
  }
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 40
    volume_type           = "gp3"
    delete_on_termination = true
  }
  network_interface {
    network_interface_id = aws_network_interface.enclave_network_interface.id
    device_index         = 0
  }
  tags = {
    Name = "enclave-instance"
  }
  user_data = templatefile(
    "${path.module}/setup_enclave.tftpl",
    {
      KMS_KEY_ID=aws_kms_key.enclave_kms_key.key_id,
      S3_BUCKET_NAME=aws_s3_bucket.enclave_bucket.bucket
    }
  )
}
