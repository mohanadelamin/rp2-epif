#!/usr/bin/env python3
import sys
import time, threading
import subprocess
import os
import datetime
from random import randrange

from subprocess import Popen

# Usage
# sudo ./xen_vm_stats.py <DIR>
delta = 3
node_list = [
    'k8s-worker-1',
    'k8s-worker-2'
]

if len(sys.argv) > 1:
    output_dir = sys.argv[1]
else:
    output_dir = "."

output_file = output_dir + "/vms_stats.csv"

if delta is None:
    print('Env has not been set properly')
    sys.exit()

def stat():
    global inbytes_start
    threading.Timer(delta, stat).start()
    p = Popen(["xentop", "-b", "-f", "-i","1"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    x = str(out).split('\\n')
    for item in x:
        for node in node_list:
            if node in item:
                #ts = str(time.time())
                ts = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%s")
                print(item)
                cpu_sec = item.split()[2]
                cpu = item.split()[3]
                mem_k = item.split()[4]
                mem = item.split()[5]
                notif = ts + "," + node + "," + cpu_sec + "," \
                        + cpu + "," + mem_k + "," + mem
                write_output(notif,output_file)

def write_output(data,output_file):
    print(data)
    with open(output_file, 'a') as f:
        f.write(data + '\n')

def main():
    header = "timestamp,node,cpu_seconds,cpu_percentage,mem_k,mem_percentage"
    write_output(header,output_file)
    stat()

if __name__ == '__main__':
    main()
