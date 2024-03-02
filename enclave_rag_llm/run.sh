#!/bin/sh

ifconfig lo 127.0.0.1

echo "127.0.0.1 . kms.us-west-1.amazonaws.com" >> /etc/hosts

nohup python3 /app/traffic_forwarder.py --local-port 443 --remote-cid 3 --remote-port 8000 &
python3 /app/server.py
