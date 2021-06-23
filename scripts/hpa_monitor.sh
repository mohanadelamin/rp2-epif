#!/usr/bin/env bash

FILE="$1/hpa_stats.txt"

echo '"Time,currentReplicas,cpuPercentage"' > $FILE

while true
do
    sleep 1
    read -rst5 DATE   < <(date +"%FT%T.%3N")
    read -rst5 REPLICAS < <(kubectl get hpa epi-bf-hpa -n epi -o jsonpath='{.status.currentReplicas}')
    read -rst5 PERCENT  < <(kubectl get hpa epi-bf-hpa -n epi -o jsonpath='{.status.currentCPUUtilizationPercentage}')
    echo "$DATE,$REPLICAS,$PERCENT"
done >> $FILE;