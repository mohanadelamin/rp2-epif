#!/usr/bin/env python3
import sys
import time, threading
import subprocess
import os
from random import randrange

from subprocess import Popen

delta = float(os.environ.get('DELTA'))
inbytes_start = 0
if delta is None:
    print('Env has not been set properly')
    sys.exit()

def stat():
    global inbytes_start
    threading.Timer(delta, stat).start()
    p = Popen(["netstat", "-i"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    x = str(out).split('\\n')
    inbytes = x[2].split()[2]
    outbytes = x[2].split()[6]
    inbytes_delta = int(inbytes) - inbytes_start
    notif = "InBytes = " +  inbytes + ", OutBytes = " + outbytes + " OldInBytes = " \
        + str(inbytes_start) + " InBytesDelta = " + str(inbytes_delta)
    inbytes_start = int(inbytes)
    process_states(x, int(inbytes_delta))
    print(notif)


def process_states(output, bytesnum):
    long_output = ""
    for i in range(bytesnum):
        long_output += str(output)
        print(long_output)

    for i in range(len(long_output)):
        text = long_output
        new = list(text)
        new[randrange(len(long_output))] = 'X'
        ''.join(new)

if __name__ == '__main__':
    stat()