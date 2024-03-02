"""
Module for forwarding traffic between the enclave and the parent instance (in both directions).
"""

# Python-native dependencies
import time
import socket
import threading

# External dependencies
import click

def server(local_port: int, remote_cid: int, remote_port: int) -> None:
    """
    """
    try:
        docking_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        docking_socket.bind(('', local_port))
        docking_socket.listen(5)

        while True:
            client_socket = docking_socket.accept()[0]

            server_socket = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
            server_socket.connect((remote_cid, remote_port))

            outgoing_thread = threading.Thread(target=forward, args=(client_socket, server_socket))
            incoming_thread = threading.Thread(target=forward, args=(server_socket, client_socket))

            outgoing_thread.start()
            incoming_thread.start()
    
    finally:
        new_thread = threading.Thread(target=server, args=(local_port, remote_cid, remote_port))
        new_thread.start()

def forward(source: socket.socket, destination: socket.socket) -> None:
    """
    """
    in_transit_data = ' '
    while in_transit_data:
        in_transit_data = source.recv(1024)
        if in_transit_data:
            destination.sendall(in_transit_data)
        else:
            source.shutdown(socket.SHUT_RD)
            destination.shutdown(socket.SHUT_WR)

@click.command()
@click.option('-lp', '--local-port', required=True)
@click.option('-rc', '--remote-cid', required=True)
@click.option('-rp', '--remote-port', required=True)
def start_traffic_forwarder(local_port: int, remote_cid: int, remote_port: int) -> None:
    """
    Kicks off the traffic forwarder on the local port and remote CID/port.
    """
    traffic_forwarder_thread = threading.Thread(target=server, args=(local_port, remote_cid, remote_port))
    traffic_forwarder_thread.start()

    while True:
        time.sleep(60)

if __name__ == '__main__':
    start_traffic_forwarder()
