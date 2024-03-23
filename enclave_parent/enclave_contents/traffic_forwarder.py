"""
Module for forwarding traffic between the enclave and the parent instance (in both directions).
"""

# Python-native dependencies
import time
import socket
import threading

# External dependencies
import click

def run_server(local_port: int, remote_cid: int, remote_port: int) -> None:
    """
    Runs the server; makes threads for both incoming traffic
    to be received and outgoing traffic to be sent out.
    """
    try:
        docking_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        docking_socket.bind(('127.0.0.1', local_port))
        docking_socket.listen(5)

        while True:
            client_socket = docking_socket.accept()[0]

            server_socket = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
            server_socket.connect((remote_cid, remote_port))

            outgoing_thread = threading.Thread(
                target=forward, args=(client_socket, server_socket))
            incoming_thread = threading.Thread(
                target=forward, args=(server_socket, client_socket))

            outgoing_thread.start()
            incoming_thread.start()

    finally:
        new_thread = threading.Thread(
            target=run_server, args=(local_port, remote_cid, remote_port))
        new_thread.start()

def forward(source: socket.socket, destination: socket.socket) -> None:
    """
    Forwards in-transit data from the
    given source to the given destination.
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
@click.option('-lp', '--local-port', required=True, type=int)
@click.option('-rc', '--remote-cid', required=True, type=int)
@click.option('-rp', '--remote-port', required=True, type=int)
def start_traffic_forwarder(
    local_port: int, remote_cid: int, remote_port: int
) -> None:
    """
    Kicks off the traffic forwarder on the local port and remote CID/port.
    """
    traffic_forwarder_thread = threading.Thread(
        target=run_server, args=(local_port, remote_cid, remote_port))
    traffic_forwarder_thread.start()
    print(
        f'Started forwarder on 127.0.0.1:{local_port} '
        f'{remote_cid}:{remote_port}'
    )
    while True:
        time.sleep(60)

if __name__ == '__main__':
    start_traffic_forwarder()
