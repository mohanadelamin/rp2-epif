#!/bin/bash
########
echo "NOT YET COMPLETE"
exit 1

#######
# Usage
# ./run_experiments.sh <EXPERIMENTS_VARIABLES> <DIR>

EXPERIMENTS_VARS=$1
OUTPUT_DIR=$2

BF_IMAGE="melamin/epi_vnf_firewall:v0.0.7"
PROXY_IMAGE="melamin/epi_proxy:v0.0.3"
SERVER_IMAGE="melamin/httpbin:v0.0.1"


echo "Reading test variables from ${EXPERIMENTS_VARS}"

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
    
    TEST_DIR="${OUTPUT_DIR}/TEST_NO_${TEST_NO}"
    echo "Creating Directory ${TEST_DIR}"
    mkdir ${TEST_DIR}

    # Deploy EPI PoC Helm
    helm repo add epi-helm https://mohanadelamin.github.io/epi-bf-helm/
    helm install epi-bf epi-helm/epi_bf_helm -n epi \
    --set bf.image=${BF_IMAGE} \
    --set bf.cpu_limit=${BF_CPU_LIMIT} \
    --set bf.mem_limit=${BF_MEM_LIMIT} \
    --set bf_hpa.maxReplicas=${HPA_MAX_REPLICAS} \
    --set bf_hpa.cpu_averageUtilization=${HPA_UTILIZATION} \
    --set bf_hpa.mem_averageUtilization=${HPA_UTILIZATION}

    # Deploy Locust helm chart to repo
    helm repo add deliveryhero https://charts.deliveryhero.io/
    # Locust test script
    kubectl create configmap loadtest-locustfile --from-file locust-test/main.py  -n epi
    kubectl create configmap loadtest-lib --from-file locust-test/lib/ -n epi
    # Deploy Locust distrubtuted load tester 
    helm install locust deliveryhero/locust -n epi --set service.type="NodePort" \
    --set loadtest.name=epif-bf-loadtest \
    --set securityContext.privileged=true \
    --set worker.image="melamin/locust-worker:v0.0.19" \
    --set worker.environment.PROXY_HOST="epi-proxy" \
    --set worker.environment.PROXY_PORT="1080" \
    --set worker.command[0]="bash" \
    --set worker.command[1]="/entrypoint.sh" \
    --set loadtest.locust_locustfile_configmap=loadtest-locustfile \
    --set loadtest.locust_lib_configmap=loadtest-lib \
    --set worker.resources.limits.cpu="1000m" \
    --set worker.resources.requests.cpu="200m" \
    --set worker.hpa.enabled=true \
    --set worker.hpa.maxReplicas=1 \
    --set worker.hpa.targetCPUUtilizationPercentage=80 \
    --set loadtest.locust_host="http://epi-server"

    echo "Setup is deploying, sleeping for 10 seconds"
    sleep 10

    # Start locust test
    echo "Starting locust request"
    python3 locust_start_request.py ${NUMBER_OF_USERS} ${SPAWN_RATE}

    timer=0
    while [[ ${timer} -lt ${RUN_TIME} ]];
    do
      echo "progress: ${timer}/${RUN_TIME}"
      ((timer++))
      sleep 1
    done;


    echo "Cleaning up setup."
    helm delete epi-bf -n epi
    helm delete locust -n epi
    kubectl delete configmap loadtest-locustfile -n epi
    kubectl delete configmap loadtest-lib -n epi

done < <(tail -n +2 $EXPERIMENTS_VARS)
