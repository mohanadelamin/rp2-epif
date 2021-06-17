#!/bin/bash

############################################################################
#epi-bf-hpa
BF_HPA_MIN_REPLICAS=1
BF_HPA_UTILIZATION=30
BF_HPA_MAX_REPLICAS=1
BF_HPA_SCALABLE_RESOURCE=cpu


#epi-bf
BF_LIMITS_CPU="1000m"
BF_LIMITS_MEM="500Mi"
BF_REQUEST_CPU="200m"
BF_REQUEST_MEM="100Mi"

#epi-server
SERVER_REPLICAS=1
SERVER_LIMITS_CPU="1000m"
SERVER_LIMITS_MEM="500Mi"
SERVER_REQUEST_CPU="200m"
SERVER_REQUEST_MEM="100Mi"

#epi-proxy
PROXY_REPLICAS=1
PROXY_LIMITS_CPU="1000m"
PROXY_LIMITS_MEM="500Mi"
PROXY_REQUEST_CPU="200m"
PROXY_REQUEST_MEM="100Mi"

#############################################################################
# Start all services wait till they are ready

# Create config files
cd yaml_configurable/ && . ./make_yamls.sh && cd ../
