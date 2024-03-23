"""
Serves as always-on proxy between the
enclave and any requests being sent to it.
"""

# Python-native dependencies
import json
import socket

# External dependencies
from flask import Flask, request, jsonify

api = Flask(__name__)

@api.route('/', methods=['POST'])
def x():
    """
    """
    vsock_socket = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
    # NOTE: 16 is the Enclave CID set in this repo's
    # securing-rag-with-tees/aws_infrastructure/setup_enclave.tftpl
    cid, port = 16, 5000
    vsock_socket.connect((cid, port))
    vsock_socket.send(str.encode(json.dumps(request.get_json())))
    received_data = json.loads(vsock_socket.recv(4096).decode())
    vsock_socket.close()
    return jsonify(received_data)

if __name__ == '__main__':
    api.run(host='0.0.0.0', port=5001, debug=True)
