#!/usr/bin/env bash

PROXY_SRC=`hostname -i`
EPI_VNF_VAR=`host $EPI_VNF | awk '/has address/ { print $4 ; exit }'`
iptables -t nat -A OUTPUT -p tcp --src $PROXY_SRC -j DNAT --to-destination $EPI_VNF_VAR:$EPI_VNF_PORT
nohup bash /monitor.sh &
sleep 1s
./proxy.py start -f
