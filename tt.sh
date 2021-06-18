#!/bin/bash
########
#echo "NOT YET COMPLETE"
#exit 1

#######
# Usage
# ./run_experiments.sh <EXPERIMENTS_VARIABLES_CSV> <DIR> <NAMESPACE>

if [ $# -ne 3 ]
  then
    echo "No arguments supplied"
    exit 1
fi


EXPERIMENTS_VARS=$1
OUTPUT_DIR=$2
NAMESPACE=$3

BF_IMAGE=pimpaardekooper/vnf_instances:http_filter_no_stress
#BF_IMAGE="melamin/epi_vnf_http_filter:v0.0.9"
#BF_IMAGE="melamin/epi_vnf_network_monitor:v0.0.9"
#BF_IMAGE="melamin/epi_vnf_firewall:v0.0.7"
PROXY_IMAGE="melamin/epi_proxy:v0.0.3"
SERVER_IMAGE="melamin/httpbin:v0.0.1"

WORKERS=("145.100.110.91" "145.100.110.92")

echo "Reading test variables from ${EXPERIMENTS_VARS}"

TEST_DIR="."

while read line
do

    IFS=',' read -r -a test_array <<< ${line}
    TEST_NO=${test_array[0]}
    NUMBER_OF_USERS=${test_array[1]}
    SPAWN_RATE=${test_array[2]}
    RUN_TIME=${test_array[3]}
    HPA_MAX_REPLICAS=${test_array[4]}
    HPA_UTILIZATION=${test_array[5]}
    BF_CPU_LIMIT=${test_array[6]}
    BF_MEM_LIMIT=${test_array[7]}

    echo ${TEST_NO}

    echo "Start Worker node monitoring"
    sudo python3 scripts/xen_vm_stats.py ${TEST_DIR} 1>/dev/null 2>/dev/null &
    sleep 10
    sudo kill -9 $(ps aux | grep xen_vm_stats | grep -v grep | awk '{print $2}')
done < <(tail -n +2 ${EXPERIMENTS_VARS})

echo "All tests are done, generated data available in ${OUTPUT_DIR}"