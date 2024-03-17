"""
Module for running the parent instance's client
app that interfaces with the Nitro Enclave.
"""

# Python-native dependencies
import json
import socket

# External dependencies
import click
import requests

def get_aws_session_credentials() -> dict:
    """
    """
    instance_profile_name = requests.get(
        'http://169.254.169.254/latest/meta-data/iam/security-credentials'
    ).text

    security_credentials = requests.get(
        'http://169.254.169.254/latest/meta-data/iam/' +\
        f'security-credentials/{instance_profile_name}'
    ).json()

    return {
        'access_key_id': security_credentials['AccessKeyId'],
        'secret_access_key': security_credentials['SecretAccessKey'],
        'token': security_credentials['Token'],
        'region': 'us-west-1'
    }

@click.command()
@click.option('-p', '--prompt', required=True)
def make_enclave_request(prompt: str):
    """
    """
    credentials = get_aws_session_credentials()
    request = credentials | {'Prompt': prompt}
    vsock_socket = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
    # NOTE: 16 is the Enclave CID set in this repo's
    # securing-rag-with-tees/aws_infrastructure/setup_enclave.tftpl
    cid, port = 16, 5000
    vsock_socket.connect((cid, port))
    vsock_socket.send(str.encode(json.dumps(request)))
    print(vsock_socket.recv(1024).decode())
    vsock_socket.close()

if __name__ == '__main__':
    make_enclave_request()
