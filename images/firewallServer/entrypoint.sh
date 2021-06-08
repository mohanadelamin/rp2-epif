#!/usr/bin/env bash
iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination 10.96.0.3:80
./rules.sh
sleep infinity
