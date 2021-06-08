#!/usr/bin/env bash

PROXY_SRC=`hostname -i`
EPI_VNF_FW_VAR=`host $EPI_VNF_FW | awk '/has address/ { print $4 ; exit }'`
iptables -t nat -A OUTPUT -p tcp --src $PROXY_SRC -j DNAT --to-destination $EPI_VNF_FW_VAR:$EPI_VNF_FW_PORT

sleep 1s
./proxy.py start -f
