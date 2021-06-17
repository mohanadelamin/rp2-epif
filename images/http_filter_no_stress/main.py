#!/usr/bin/env python3
import os
import time
from multiprocessing import Process, active_children, cpu_count, Pipe
from random import randrange
from netfilterqueue import NetfilterQueue
from scapy.all import *
import requests

FIB_N = 50

def callback(pkt):
        parsed = str(pkt.get_payload())
        print("Packet Received: " + parsed)
        ts = str(time.time())

        if 'hack' in parsed:
            # process_pkt(parsed)
            pkt.drop()
            print(ts + ": Packet dropped")
        else:
            # process_pkt(parsed)
            pkt.accept()
            print(ts + ": Packet accepted")


def process_pkt(packet):
    for i in range(len(packet)):
        text = packet
        new = list(text)
        new[randrange(len(packet))] = 'X'
        ''.join(new)

def main():
    print("I am ready to parse packets.")
    nfqueue = NetfilterQueue()
    nfqueue.bind(1, callback)
    try:
        nfqueue.run()
    except KeyboardInterrupt as e:
        print(e)

if __name__ == '__main__':
    main()
