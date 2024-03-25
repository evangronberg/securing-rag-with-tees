#!/bin/sh

# Assign an IP address to local loopback 
ip addr add 127.0.0.1/32 dev lo

ip link set dev lo up

# Add a hosts record, pointing target site calls to local loopback
echo "127.0.0.1   kms.us-east-1.amazonaws.com" >> /etc/hosts

touch /app/libnsm.so

# Start the traffic_forwarder and server
python3.8 /app/traffic_forwarder.py --local-port 443 --remote-cid 3 --remote-port 8000 &
python3.8 /app/llm_app.py
