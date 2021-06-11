#!/bin/bash

# Look for the SYN packet and create the list:
iptables -A FORWARD -m recent -p tcp --syn --set

# Look for the ACK packet and update the list:
iptables -A FORWARD -m recent -p tcp --tcp-flags PSH,SYN,ACK ACK --update

# This is the right packet: look for our string pattern and DROP it
# if we find it.
# Then, delete our list, we don't want to filter any further packet:
iptables -A FORWARD -m recent -p tcp --tcp-flags PSH,ACK PSH,ACK --remove
# EOF
iptables-save


