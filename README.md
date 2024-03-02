# Securing RAG with TEEs

This is the repository for the "Securing Retrieval Augmented Generation (RAG) with Trusted Execution Environments (TEEs)" paper. It seeks secure a RAG-enabled LLM (Large Language Model) using TEEs – namely, the AWS TEE offering, Nitro Enclaves.

## Usage

Once you have cloned this repo, run the following commands to set up your TEE:

```bash
cd aws_infrastructure
terraform init
terraform apply -auto-approve
```

> Note that, for the above commands to work, you'll need (1) the AWS CLI installed and set up with an access key for your account and (2) Terraform installed.

Once you have done this, access the AWS Management Console and use EC2 Instance Connect to connect to the `enclave-instance` EC2. In the terminal, run the following commands:

```bash
cd /securing-rag-with-tees
sudo ./.venv/bin/python make_enclave_request.py --prompt "<YOUR LLM PROMPT HERE>"
```
