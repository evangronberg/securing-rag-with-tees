"""
Module for running the LLM on RAG-enhanced prompts.
"""

# Python-native dependencies
import os
import json
import base64
import socket

# External dependencies
import boto3
import requests
import transformers

def decrypt_prompt(payload: dict) -> str:
    """
    Uses the payload's included credentials to decrypt
    the payload's ciphertext (i.e., the encrypted prompt).
    """
    kms_client = boto3.client(
        'kms',
        region_name=payload['region'],
        aws_access_key_id=payload['access_key_id'],
        aws_secret_access_key=payload['secret_access_key'],
        aws_session_token=payload['token']
    )
    ciphertext_blob = base64.b64decode(payload['ciphertext'])
    prompt_plaintext = kms_client.decrypt(
        CiphertextBlob=ciphertext_blob)['Plaintext'].decode()
    return prompt_plaintext

def encrypt_llm_response(payload: dict, llm_response: str) -> bytes:
    """
    Uses the original payload's included credentials
    to encrypt the LLM's response to the prompt.
    """
    kms_client = boto3.client(
        'kms',
        region_name=payload['region'],
        aws_access_key_id=payload['access_key_id'],
        aws_secret_access_key=payload['secret_access_key'],
        aws_session_token=payload['token']
    )
    kms_response = kms_client.encrypt(
        KeyId=os.environ['KMS_KEY_ID'],
        Plaintext=llm_response,
    )
    llm_response_ciphertext = kms_response['CiphertextBlob']
    return llm_response_ciphertext

def run_app() -> None:
    """
    """
    vsock_socket = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
    cid = socket.VMADDR_CID_ANY # To listen for a connection from any CID
    port = 5000
    vsock_socket.bind((cid, port))
    vsock_socket.listen()

    while True:
        connection, _ = vsock_socket.accept()
        payload = dict(json.loads(connection.recv(4096).decode()))
        prompt = decrypt_prompt(payload)

        if prompt == 'KMS Error. Decryption Failed.':
            result = {'error': 'Decryption of LLM prompt failed due to KMS error'}
        else:
            llm_response = prompt.upper() # TODO: Insert actual LLM here
            encrypted_llm_response= encrypt_llm_response(payload, llm_response)
            result = {
                'EncryptedLLMResponse': base64.b64encode(
                    encrypted_llm_response).decode('utf-8')
            }
        connection.send(str.encode(json.dumps(result)))
        connection.close()

if __name__ == '__main__':
    run_app()
