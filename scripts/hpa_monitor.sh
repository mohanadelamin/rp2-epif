#!/usr/bin/env bash

# Usage
# ./hpa_mem_monitor.sh <DIR> <NAMESPACE>

FILE="$1/hpa_stats.txt"

HPA="epi-bf-hpa"

echo '"Time,currentReplicas,cpuPercentage"' > $FILE

while true
do
    sleep 1
    read -rst5 DATE   < <(date +"%FT%T.%3N")
    read -rst5 REPLICAS < <(kubectl get hpa ${HPA} -n ${NAMESPACE} -o jsonpath='{.status.currentReplicas}')
    read -rst5 PERCENT  < <(kubectl get hpa ${HPA} -n ${NAMESPACE} -o jsonpath='{.status.currentCPUUtilizationPercentage}')
    echo "$DATE,$REPLICAS,$PERCENT"
done >> $FILE;