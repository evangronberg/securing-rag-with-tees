# Securing RAG with TEEs

This is the code repository associated with the "Securing Retrieval Augmented Generation (RAG) with Trusted Execution Environments (TEEs)" paper. It seeks secure a RAG-enabled LLM (Large Language Model) using TEEs – namely, the AWS TEE offering, Nitro Enclaves.

## Usage

Once you have cloned this repo, run the following commands to set up your AWS environment:

```bash
cd aws_infrastructure
terraform init
terraform apply -auto-approve
```

> Note that, for the above commands to work, you'll need (1) the AWS CLI installed set up with an access key for your account and (2) Terraform installed.
