#!/bin/bash
cd /

# THE BLOCK OF COMMANDS BELOW COME FROM THE FOLLOWING LINK:
# https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave-cli-install.html

# Install the Nitro CLI.
sudo dnf install aws-nitro-enclaves-cli -y
# Install the Nitro Enclaves development tools needed to build enclave images.
# The development tools also includes some sample applications.
sudo dnf install aws-nitro-enclaves-cli-devel -y
# Add your user to the ne user group.
sudo usermod -aG ne ec2-user
# Add your user to the docker user group.
sudo usermod -aG docker ec2-user
# Run the following command to allocate the resource specified in the configuration
# file (/etc/nitro_enclaves/allocator.yaml) and to ensure that they are automatically
# allocated every time the instance starts.
sudo systemctl enable --now nitro-enclaves-allocator.service
# Start the Docker service and ensure that it starts every time the instance starts.
sudo systemctl enable --now docker


# Set the memory and CPU limit for the enclave
sudo sh -c "echo -e 'memory_mib: 512\ncpu_count: 2' > /etc/nitro_enclaves/allocator.yaml"

# Get the code repository and download the model
sudo dnf update
sudo dnf install git -y
sudo git clone https://github.com/evangronberg/securing-rag-with-tees.git
cd securing-rag-with-tees
sudo curl -O https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo python3 -m pip install virtualenv
sudo python3 -m virtualenv .venv 
source .venv/bin/activate
sudo pip install -r requirements.txt
sudo python download_model.py


# THE BLOCK OF COMMANDS BELOW ARE ADAPTED FROM THE FOLLOWING LINK:
# https://docs.aws.amazon.com/enclaves/latest/user/getting-started.html

# Build the Docker image that will go inside the Enclave
docker build enclave_rag_llm -t enclave_rag_llm
# Convert the Docker image to an Enclave image file
nitro-cli build-enclave --docker-uri enclave_rag_llm:latest --output-file enclave_rag_llm.eif
# Run the Enclave using the image file produced above; specify Enclave size
nitro-cli run-enclave --cpu-count 2 --memory 512 --enclave-cid 16 --eif-path enclave_rag_llm.eif --debug-mode
