#!/usr/bin/env python3
import sys
import time, threading
import subprocess
import os
import datetime
from random import randrange

from subprocess import Popen

delta = 3
node_list = [
    'k8s-worker-1',
    'k8s-worker-2'
]

if delta is None:
    print('Env has not been set properly')
    sys.exit()

def stat():
    global inbytes_start
    threading.Timer(delta, stat).start()
    p = Popen(["xentop", "-b", "-f", "-i","1"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    x = str(out).split('\\n')
    #print(x)
    for item in x:
        for node in node_list:
            if node in item:
                #ts = str(time.time())
                ts = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%s")
                cpu_sec = item.split()[2]
                cpu = item.split()[3]
                mem_k = item.split()[4]
                mem = item.split()[5]
                notif = ts + "," + node + "," + cpu_sec + "," \
                        + cpu + "," + mem_k + "," + mem
                print(notif)

def main():
    print("timestamp,node,cpu_seconds,cpu_percentage,mem_k,mem_percentage")
    stat()

if __name__ == '__main__':
    main()
