#!/bin/bash

#epi-bf-hpa
#BF_HPA_MIN_REPLICAS=1
#BF_HPA_UTILIZATION=30
#BF_HPA_MAX_REPLICAS=1
#BF_HPA_SCALABLE_RESOURCE=cpu
#
#
##epi-bf
#BF_LIMITS_CPU="1000m"
#BF_LIMITS_MEM="500Mi"
#BF_REQUEST_CPU="200m"
#BF_REQUEST_MEM="100Mi"
##epi-proxy
#
##epi-server
#SERVER_REPLICAS=1
#SERVER_LIMITS_CPU="1000m"
#SERVER_LIMITS_MEM="500Mi"
#SERVER_REQUEST_CPU="200m"
#SERVER_REQUEST_MEM="100Mi"
#
#epi-proxy
#PROXY_REPLICAS=1
#PROXY_LIMITS_CPU="1000m"
#PROXY_LIMITS_MEM="500Mi"
#PROXY_REQUEST_CPU="200m"
#PROXY_REQUEST_MEM="100Mi"

DIRECTORY="../yaml_generated"

mkdir ${DIRECTORY}

echo "bf ${BF_HPA_MIN_REPLICAS}"
echo "directory: ${DIRECTORY}/${NAME}"

# Variables epi-bf-hpa
MIN_REPLICAS=${BF_HPA_MIN_REPLICAS}
UTILIZATION=${BF_HPA_UTILIZATION}
MAX_REPLICAS=${BF_HPA_MAX_REPLICAS}
SCALABLE_RESOURCE=${BF_HPA_SCALABLE_RESOURCE}
NAME="epi-bf-hpa.yaml"


# Create yaml file for epi-bf-hpa

declare -A array=( ["MIN_REPLICAS"]=${MIN_REPLICAS} ["MAX_REPLICAS"]=${MAX_REPLICAS} ["SCALABLE_RESOURCE"]=${SCALABLE_RESOURCE} ["UTILIZATION"]=${UTILIZATION} )

template=`cat ${NAME}`

for var in "${!array[@]}"
do
	#echo "${var}=${array[$var]}"
	template=$(echo "${template}" | sed "s/${var}/${array[$var]}/g")
done

echo "template > ${DIRECTORY}/${NAME}"
echo "${template}" > "${DIRECTORY}/${NAME}"

# Create yaml file for epi-bf

REPLICAS=${BF_REPLICAS}
LIMITS_CPU=${BF_LIMITS_CPU}
LIMITS_MEM=${BF_LIMITS_MEM}
REQUEST_CPU=${BF_REQUEST_CPU}
REQUEST_MEM=${BF_REQUEST_MEM}
NAME="epi-bf.yaml"
#IMAGE="pimpaardekooper\/vnf_instances:http_filter_no_stress"

declare -A array=( ["REPLICAS"]=${REPLICAS} ["LIMITS_CPU"]=${LIMITS_CPU} ["LIMITS_MEM"]=${LIMITS_MEM} ["REQUEST_CPU"]=${REQUEST_CPU} ["REQUEST_MEM"]=${REQUEST_MEM} )

template=`cat ${NAME}`

for var in "${!array[@]}"
do
	echo "${var}=${array[$var]}"
	template=$(echo "${template}" | sed "s/${var}/${array[$var]}/g")
done


echo "${template}" > "${DIRECTORY}/${NAME}"
#echo "${template}"

# Create yaml file for epi-proxy.yaml

REPLICAS=${PROXY_REPLICAS}
LIMITS_CPU=${PROXY_LIMITS_CPU}
LIMITS_MEM=${PROXY_LIMITS_MEM}
REQUEST_CPU=${PROXY_REQUEST_CPU}
REQUEST_MEM=${PROXY_REQUEST_MEM}
NAME="epi-proxy.yaml"


declare -A array=( ["REPLICAS"]=${REPLICAS} ["LIMITS_CPU"]=${LIMITS_CPU} ["LIMITS_MEM"]=${LIMITS_MEM} ["REQUEST_CPU"]=${REQUEST_CPU} ["REQUEST_MEM"]=${REQUEST_MEM} )

template=`cat ${NAME}`


for var in "${!array[@]}"
do
	echo "${var}=${array[$var]}"
	template=$(echo "${template}" | sed "s/${var}/${array[$var]}/g")
done

echo "${template}" > "${DIRECTORY}/${NAME}"

# Create yaml file for epi-server.yaml

REPLICAS=${SERVER_REPLICAS}
LIMITS_CPU=${SERVER_LIMITS_CPU}
LIMITS_MEM=${SERVER_LIMITS_MEM}
REQUEST_CPU=${SERVER_REQUEST_CPU}
REQUEST_MEM=${SERVER_REQUEST_MEM}
NAME="epi-server.yaml"


declare -A array=( ["REPLICAS"]=${REPLICAS} ["LIMITS_CPU"]=${LIMITS_CPU} ["LIMITS_MEM"]=${LIMITS_MEM} ["REQUEST_CPU"]=${REQUEST_CPU} ["REQUEST_MEM"]=${REQUEST_MEM} )

template=`cat ${NAME}`

for var in "${!array[@]}"
do
	echo "${var}=${array[$var]}"
	template=$(echo "${template}" | sed "s/${var}/${array[$var]}/g")
done

echo "${template}" > "${DIRECTORY}/${NAME}"
