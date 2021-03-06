#!/usr/bin/env python3
import requests
import json5
import json
from bs4 import BeautifulSoup
import demjson
import pandas as pd
import os
import sys

# Usage:
# python3 get_locust_data.py <DIR> <LOCUST_SVC_URL>

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
fails = []
response_times_percentile_50 = []
response_times_percentile_95 = []

for y in x["current_rps"]:
    users.append(y['users'])
    values.append(y['value'])


for y in x["current_fail_per_sec"]:
    fails.append(y['value'])

for y in x["response_time_percentile_50"]:
    response_times_percentile_50.append(y['value'])

for y in x["response_time_percentile_95"]:
    response_times_percentile_95.append(y['value'])


dataframe = {'users': users, 'values': values, 'time': x["time"], "fails": fails, "response_time_50": response_times_percentile_50, "response_time_95": response_times_percentile_95}
df = pd.DataFrame(data=dataframe)
df.to_csv(f"{output_dir}/locust_data.csv")
