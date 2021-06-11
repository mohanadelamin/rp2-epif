#!/usr/bin/env bash
iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination 10.96.0.3:80
iptables -t nat -A POSTROUTING -j MASQUERADE
python ./data/main.py
