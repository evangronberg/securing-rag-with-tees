#!/bin/bash

# THE BELOW COMMANDS ARE ADAPTED FROM THE FOLLOWING LINK:
# https://docs.aws.amazon.com/enclaves/latest/user/getting-started.html

# Build the Docker image that will go inside the Enclave
docker build enclave_rag_llm -t enclave_rag_llm

# Convert the Docker image to an Enclave image file
nitro-cli build-enclave --docker-uri enclave_rag_llm:latest --output-file enclave_rag_llm.eif

# Run the Enclave using the image file produced above; specify Enclave size
nitro-cli run-enclave --cpu-count 2 --memory 512 --enclave-cid 16 --eif-path enclave_rag_llm.eif --debug-mode
