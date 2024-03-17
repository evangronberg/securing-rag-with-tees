# Securing RAG with TEEs

> Consider this video for model choice: https://www.youtube.com/watch?v=NFgEgqua-fg

This is the repository for the "Securing Retrieval Augmented Generation (RAG) with Trusted Execution Environments (TEEs)" paper. It seeks secure a RAG-enabled LLM (Large Language Model) using TEEs – namely, the AWS TEE offering, Nitro Enclaves.

## Usage

Once you have cloned this repo, run the launch script inside the repository's main directory to set up your TEE:

```bash
source launch.sh
```

> Note that, for the script to work, you'll need (1) the AWS CLI installed and set up with an access key for your account and (2) Terraform installed.

Once you have done this, access the AWS Management Console and use EC2 Instance Connect to tunnel into `enclave-instance`. Then run the following commands:

```bash
cd /securing-rag-with-tees
sudo ./.venv/bin/python make_enclave_request.py --prompt "<YOUR LLM PROMPT HERE>"
```
