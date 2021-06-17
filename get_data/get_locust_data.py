import requests
import json5
import json
from bs4 import BeautifulSoup
import demjson
import pandas as pd
import os
import sys

if len(sys.argv) < 2:
    print("give filename")
    exit(1)

output_dir = sys.argv[1]


port = os.popen("kubectl get svc locust | grep -Eo '8089:[0-9]*'").read()
port = port.split(":")[1]
URL = f'http://localhost:{port}'
page = requests.get(URL)

soup = BeautifulSoup(page.content, 'html.parser')
results = soup.find_all('script')

stats_history = str(results[-3])
x = stats_history.split("\n")
x = x[2:-1]
x = "\n".join(x)
x = x.replace("var stats_history = ", "")
x = x.replace("\n", "")
last_bit = x[-1:] 
x = x[:-3] + x[-2:]
x = x[:-1]
x = json.loads(x)

with open('data.txt', 'w') as outfile:
        json.dump(x, outfile)

values = []
users = []

for y in x["current_rps"]:
    users.append(y['users'])
    values.append(y['value'])

dataframe = {'users': users, 'values': values, 'time': x["time"]}
df = pd.DataFrame(data=dataframe)
df.to_csv(f"{output_dir}locust_data.csv")
