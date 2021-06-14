#!/usr/bin/env bash

#export PROXY_HOST="${1}"

# iptables -t nat -A OUTPUT ! -d $PROXY_HOST -o eth0 -p tcp -m tcp -j REDIRECT --to-ports 42000

./redirector.py
sleep 1s
./client.py
