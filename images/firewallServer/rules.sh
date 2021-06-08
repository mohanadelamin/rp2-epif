#!/bin/bash
sysctl -w net.ipv4.ip_forward=1
# sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
# iptables -t nat -A PREROUTING -p tcp --dport 1234 -j DNAT --to-destination <proxy IP:port>
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables-save


