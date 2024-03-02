terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-1"
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

data "template_file" "enclave_setup_script" {
  template = file("${path.module}/setup_enclave.tpl")

  vars = {
    KMS_KEY_ID = aws_kms_key.enclave_kms_key.id
  }
}

resource "aws_instance" "enclave_instance" {
  ami           = "ami-07619059e86eaaaa2" # Amazon Linux 2023 AMI
  instance_type = "m5.xlarge"

  enclave_options {
    enabled = true
  }
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 20
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
  user_data = data.template_file.enclave_setup_script.rendered
}
