#!/bin/bash
cd /

# THE BELOW COMMANDS (EXCEPT THE LAST ONE) COME FROM THE FOLLOWING LINK:
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
