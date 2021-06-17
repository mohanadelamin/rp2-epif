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

port = os.popen("kubectl get svc locust | grep -Eo '8089:[0-9]*'").read()
port = port.split(":")[1]
URL = f'http://localhost:{port}'
print(f'{URL}/swarm')
res = requests.post(f'{URL}/swarm', data=payload)

print(res)
