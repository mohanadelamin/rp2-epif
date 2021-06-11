#!/usr/bin/env bash
iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination 10.96.0.3:80
iptables -t nat -A POSTROUTING -j MASQUERADE
tc qdisc add dev eth0 root handle 1: htb default 0xfffe 
tc class add dev eth0 classid 1:0xffff parent 1: htb rate 1000000000 
tc class add dev eth0 classid 1:0xfffe parent 1:0xffff htb rate $BITRATE ceil $BITRATE
sleep infinity