#!/usr/bin/env bash
sysctl -w net.ipv4.ip_forward=1
EPI_SERVER_VAR=`host $EPI_SERVER | awk '/has address/ { print $4 ; exit }'`
iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination $EPI_SERVER_VAR:$EPI_SERVER_PORT
iptables -t nat -A POSTROUTING -j MASQUERADE
./rules.sh
sleep infinity
