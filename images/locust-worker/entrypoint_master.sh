#!/usr/bin/env bash


# LOCUST_WORKER_SRC=`hostname -i`
# EPI_VNF_FW_VAR=`host $EPI_VNF_FW | awk '/has address/ { print $4 ; exit }'`

# iptables -v -t nat -A OUTPUT --src $LOCUST_WORKER_SRC -p tcp ! --dport 5557 -j DNAT --to-destination $EPI_VNF_FW_VAR:$EPI_VNF_FW_PORT

iptables -t nat -A OUTPUT ! -d $PROXY_HOST -o eth0 -p tcp ! --dport 5557 -m tcp -j REDIRECT --to-ports 42000

sleep 1s

nohup bash /monitor.sh &

iptables-save

/usr/bin/python3 redirector.py
sleep 1s

/usr/bin/python3 /usr/local/bin/locust --master 