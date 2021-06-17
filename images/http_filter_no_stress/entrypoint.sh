#!/usr/bin/env bash
EPI_SERVER_VAR=`host $EPI_SERVER | awk '/has address/ { print $4 ; exit }'`
iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination $EPI_SERVER_VAR:$EPI_SERVER_PORT
iptables -A FORWARD -j NFQUEUE --queue-num 1
iptables -t nat -A POSTROUTING -j MASQUERADE
nohup bash /monitor.sh &
./main.py