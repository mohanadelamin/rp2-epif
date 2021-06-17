#!/bin/bash

# Variables epi-bf-hpa
MIN_REPLICAS=1
UTILIZATION=30
MAX_REPLICAS=1
SCALABLE_RESOURCE=cpu



# Create yaml file for epi-bf-hpa

declare -A array=( ["MIN_REPLICAS"]=${MIN_REPLICAS} ["MAX_REPLICAS"]=${MAX_REPLICAS} ["SCALABLE_RESOURCE"]=${SCALABLE_RESOURCE} ["UTILIZATION"]=${UTILIZATION} )

template=`cat epi-bf-hpa.yaml`

for var in "${!array[@]}"
do
	#echo "${var}=${array[$var]}"
	template=$(echo "${template}" | sed "s/${var}/${array[$var]}/g")
done

#echo "${template}"

# Create yaml file for epi-bf

REPLICAS=1
LIMITS_CPU="1000m"
LIMITS_MEM="500Mi"
REQUEST_CPU="200m"
REQUEST_MEM="100Mi"
IMAGE="pimpaardekooper/vnf_instances:http_filter_no_stress"

declare -A array=( ["REPLICAS"]=${REPLICAS} ["LIMITS_CPU"]=${LIMITS_CPU} ["LIMITS_MEM"]=${LIMITS_MEM} ["REQUEST_CPU"]=${REQUEST_CPU} ["REQUEST_MEM"]=${REQUEST_MEM} ["IMAGE"]=${IMAGE} )

template=`cat epi-bf.yaml`

echo 

for var in "${!array[@]}"
do
	echo "${var}=${array[$var]}"
	template=$(echo "${template}" | sed "s/${var}/${array[$var]}/g")
done

echo "${template}"



