#!/usr/bin/env python3
import sys
import time, threading
import subprocess
import os
from subprocess import Popen

delta = float(os.environ.get('DELTA'))

if delta is None:
    print('Env has not been set properly')
    sys.exit()

def stat():
    threading.Timer(delta, stat).start()
    p = Popen(["netstat", "-i"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    x = str(out).split('\\n')
    inbytes = x[2].split()[2]
    outbytes = x[2].split()[6]
    notif = "InBytes = " +  inbytes + ", OutBytes = " + outbytes
    print(notif)

if __name__ == '__main__':
    stat()