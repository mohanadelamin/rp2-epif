#!/usr/bin/env bash

FILE="$1/hpa_stats.txt"

echo '"Time,currentReplicas,memPercentage"' > $FILE

while true
do
    sleep 1
    read -rst5 DATE   < <(date +"%FT%T.%3N")
    read -rst5 REPLICAS < <(kubectl get hpa epi-bf-hpa-mem -n epi -o jsonpath='{.status.currentReplicas}')
    read -rst5 PERCENT  < <(kubectl get hpa epi-bf-hpa-mem -n epi -o jsonpath='{.metadata.annotations.autoscaling\.alpha\.kubernetes\.io/current-metrics}' | jq '.[0].resource.currentAverageUtilization')
    echo "$DATE,$REPLICAS,$PERCENT"
done >> $FILE;