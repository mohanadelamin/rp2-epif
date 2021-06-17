#!/bin/bash

PORT_LOCUST=$(kubectl get svc locust | grep -Eo '8089:[0-9]*')

PORT_LOCUST_T=$(kubectl get svc locust | grep -Eo '8089:[0-9]*')

IFS=":"
read -ra array <<<"${PORT_LOCUST_T}"

for i in "${array[@]}";
do
echo "$i"
done;

PORT_LOCUST=${array[1]}

URL="http://localhost:${PORT_LOCUST}"
echo "URL: ${URL}"
echo "Command: curl --silent --output /dev/stderr --write-out "%\{http_code\}" ${URL}"
echo -e "\n"
curl --write-out '%{http_code}' "$URL"
echo -e "\n"
STATUS_CODE=$(curl --silent --output /dev/stderr --write-out '%{http_code}' "${URL}")
echo "http://localhost:${PORT_LOCUST}"

echo "while loop res: ${STATUS_CODE}"

