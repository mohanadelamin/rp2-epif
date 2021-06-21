#!/usr/bin/env python3
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

URL = sys.argv[2]
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

values = []
users = []

for y in x["current_rps"]:
    users.append(y['users'])
    values.append(y['value'])

dataframe = {'users': users, 'values': values, 'time': x["time"]}
df = pd.DataFrame(data=dataframe)
df.to_csv(f"{output_dir}/locust_data.csv")
