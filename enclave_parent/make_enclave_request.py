"""
Module for running the parent instance's client
app that interfaces with the Nitro Enclave.
"""

# Python-native dependencies
import base64

# External dependencies
import click
import boto3
import requests

def get_aws_session_credentials() -> dict:
    """
    """
    token_url = 'http://169.254.169.254/latest/api/token'
    token_headers = {'X-aws-ec2-metadata-token-ttl-seconds': '21600'}
    token_response = requests.put(token_url, headers=token_headers)
    token = token_response.text

    metadata_url = 'http://169.254.169.254/latest/meta-data'
    metadata_headers = {'X-aws-ec2-metadata-token': token}

    instance_profile_name = requests.get(
        f'{metadata_url}/iam/security-credentials/',
        headers=metadata_headers
    ).text

    security_credentials = requests.get(
        f'{metadata_url}/iam/security-credentials/{instance_profile_name}',
        headers=metadata_headers
    ).json()

    return {
        'access_key_id': security_credentials['AccessKeyId'],
        'secret_access_key': security_credentials['SecretAccessKey'],
        'token': security_credentials['Token'],
        'region': 'us-west-1'
    }

def encrypt_prompt(kms, prompt: str):
    """
    """
    encrypted_prompt = base64.b64encode(kms.encrypt(
        KeyId='alias/enclave-kms-key-alias', Plaintext=prompt
    )['CiphertextBlob']).decode() # TODO: Get rid of the u''?
    return encrypted_prompt

def decrypt_llm_response(kms, enclave_response):
    """
    """
    decrypted_llm_response = kms.decrypt(
        CiphertextBlob=base64.b64decode(enclave_response)
    )['Plaintext'].decode()
    return decrypted_llm_response

@click.command()
@click.option('-p', '--prompt', required=True)
def make_enclave_request(prompt: str) -> None:
    """
    """
    kms = boto3.client('kms', region_name='us-west-1')
    encrypted_prompt = encrypt_prompt(kms, prompt)
    credentials = get_aws_session_credentials()
    request = credentials | {'EncryptedPrompt': encrypted_prompt}
    enclave_response = requests.post(
        'http://127.0.0.1:5001', json=request, timeout=30
    ).json()
    decrypted_llm_response = decrypt_llm_response(
        kms, enclave_response['EncryptedData']
    )
    print(decrypted_llm_response)

if __name__ == '__main__':
    make_enclave_request()
