zip -r enclave_parent.zip ./enclave_parent
cd aws_infrastructure
terraform init
terraform apply -auto-approve
cd ..
rm enclave_parent.zip
