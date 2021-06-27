#!/usr/bin/env bash

# Usage
# ./hpa_mem_monitor.sh <DIR> <NAMESPACE>

FILE="$1/hpa_stats.txt"

HPA="epi-bf-hpa-mem"

echo '"Time,currentReplicas,memPercentage"' > $FILE

while true
do
    sleep 1
    read -rst5 DATE   < <(date +"%FT%T.%3N")
    read -rst5 REPLICAS < <(kubectl get hpa ${HPA} -n ${NAMESPACE} -o jsonpath='{.status.currentReplicas}')
    read -rst5 PERCENT  < <(kubectl get hpa ${HPA} -n ${NAMESPACE} -o jsonpath='{.metadata.annotations.autoscaling\.alpha\.kubernetes\.io/current-metrics}' | jq '.[0].resource.currentAverageUtilization')
    echo "$DATE,$REPLICAS,$PERCENT"
done >> $FILE;