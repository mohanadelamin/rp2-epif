#!/usr/bin/env python3
import requests
import os
import sys

if len(sys.argv) < 3:
    print("Give user count and spawn rate")
    exit(1)

payload = {
'user_count': int(sys.argv[1]),
'spawn_rate': int(sys.argv[2]),
'host': 'http://epi-server',
}


URL=sys.argv[3]
print(f'{URL}/swarm')
res = requests.post(f'{URL}/swarm', data=payload)

print(res)
