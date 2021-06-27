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

# Variables to enable or disable CPU and Memroy HPA
HPA_CPU_ENABLED=false
HPA_MEM_ENABLED=true

# K8s service type for the BF
SERVICE_TYPE="LoadBalancer"

# Images
BF_IMAGE="melamin/epi_vnf_http_filter:v0.0.9"
PROXY_IMAGE="pimpaardekooper/vnf_instances:proxy"
SERVER_IMAGE="pimpaardekooper/vnf_instances:server"
LOCUST_WORKER_IMAGE="pimpaardekooper/vnf_instances:locust_worker"

# IP Address of worker nodes.
WORKERS=("145.100.110.91" "145.100.110.92")

echo "Reading test variables from ${EXPERIMENTS_VARS}"

# loop through all test senarios.
for line in $(tail -n +2 ${EXPERIMENTS_VARS})
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


    echo "Running Test number ${TEST_NO}"
    NOW=$( date '+%Y%m%d%H%M%S' )
    TEST_DIR="${OUTPUT_DIR}/TEST_NO_${TEST_NO}"
    echo "Creating Directory ${TEST_DIR}"
    mkdir ${TEST_DIR}

    echo "${BF_CPU_LIMIT},0,${BF_MEM_LIMIT},0" > "${TEST_DIR}/bf_milicore.txt"

    echo "Start Worker node monitoring"
    sudo python3 scripts/xen_vm_stats.py ${TEST_DIR} 1>/dev/null 2>/dev/null &
    # Deploy EPI PoC Helm
    echo "Deploying the Briding function, Proxy, and Server"
    helm repo add epi-helm https://mohanadelamin.github.io/epi-bf-helm/
    helm install epi-bf epi-helm/epi_bf_helm -n ${NAMESPACE} \
    --set bf.image=${BF_IMAGE} \
    --set bf.cpu_limit=${BF_CPU_LIMIT} \
    --set bf.mem_limit=${BF_MEM_LIMIT} \
    --set bf_hpa.cpu_enabled=${HPA_CPU_ENABLED} \
    --set bf_hpa.mem_enabled=${HPA_MEM_ENABLED} \
    --set bf_hpa.maxReplicas=${HPA_MAX_REPLICAS} \
    --set bf_hpa.cpu_averageUtilization=${HPA_UTILIZATION} \
    --set bf_hpa.mem_averageUtilization=${HPA_UTILIZATION} \
    --set proxy.image=${PROXY_IMAGE} \
    --set server.image=${SERVER_IMAGE} \
    --set bf.service_type=${SERVICE_TYPE}

    # Deploy Locust helm chart to repo
    echo "Deploying Locust load generator"
    helm repo add deliveryhero https://charts.deliveryhero.io/
    # Locust test script
    kubectl create configmap loadtest-locustfile --from-file locust-test/main.py  -n ${NAMESPACE}
    kubectl create configmap loadtest-lib --from-file locust-test/lib/ -n ${NAMESPACE}
    # Deploy Locust distrubtuted load tester 
    helm install locust deliveryhero/locust -n ${NAMESPACE} \
    --set service.type="LoadBalancer" \
    --set loadtest.name=epif-bf-loadtest \
    --set securityContext.privileged=true \
    --set worker.image=${LOCUST_WORKER_IMAGE} \
    --set worker.environment.PROXY_HOST="epi-proxy" \
    --set worker.environment.PROXY_PORT="1080" \
    --set worker.command[0]="bash" \
    --set worker.command[1]="/entrypoint.sh" \
    --set loadtest.locust_locustfile_configmap=loadtest-locustfile \
    --set loadtest.locust_lib_configmap=loadtest-lib \
    --set loadtest.locust_host="http://epi-server" \
    --set image.pullPolicy="Always"
    # --set worker.hpa.enabled=true \
    # --set worker.hpa.maxReplicas=5 \
    # --set worker.hpa.targetCPUUtilizationPercentage=80 \
    # --set worker.resources.limits.cpu="3000m" \
    # --set worker.resources.requests.cpu="200m" \

    echo "Setup is deploying, sleeping for 10 seconds"
    sleep 10

    # Start HPA monitoring script if HPA is enabled

    if [ ${HPA_CPU_ENABLED} = true ]
    then
        echo "Start the HPA Monitoring script"
        bash scripts/hpa_monitor.sh ${TEST_DIR} ${NAMESPACE} &
    fi

    if [ ${HPA_MEM_ENABLED} = true ]
    then
        echo "Starting the Memory HPA monitroing script"
        bash scripts/hpa_mem_monitor.sh ${TEST_DIR} ${NAMESPACE} &
    fi

    # CHECK if Locust is alive.
    while test -z "${LOCUST_SVC_IP}"
    do
        echo "Checking for Locust Serivce IP and Port"
        LOCUST_SVC_IP=$(kubectl get svc locust -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        sleep 2
    done
    LOCUST_SVC_PORT=$(kubectl get svc locust -n ${NAMESPACE} -o jsonpath='{.spec.ports[?(@.name=="master-p3")].port}')
    LOCUST_SVC_URL="http://${LOCUST_SVC_IP}:${LOCUST_SVC_PORT}"
    echo "Locust service URL is ${LOCUST_SVC_URL}"
    echo "Checking if Locust service is ready."
    STATUS_CODE=$(curl --silent --max-time 3 --output /dev/null --write-out '%{http_code}' "${LOCUST_SVC_URL}")

    # Wait till locust is ready
    while test "${STATUS_CODE}" != "200"
    do
        echo "Locust not ready yet, checking again!"
        STATUS_CODE=$(curl --silent --max-time 3 --output /dev/null --write-out '%{http_code}' "${LOCUST_SVC_URL}")
        sleep 2
    done

    echo "Locust retrun $STATUS_CODE, Service is ready."
    echo "Locust is starting, sleeping for 10 seconds"
    sleep 10
    # Start locust test
    echo "Starting locust request"
    python3 scripts/locust_start_request.py ${NUMBER_OF_USERS} ${SPAWN_RATE} ${LOCUST_SVC_URL}

    COUNTER=0
    MAX_PODS=10

    timer=0
    while [[ ${timer} -lt ${RUN_TIME} ]];
    do
        echo "progress: ${timer}/${RUN_TIME}"
        ((timer++))
        sleep 1
    done;

    echo "Test done, Starting data collection after 5 seconds"
    sleep 5

    echo "Collecting Locust stats"
    python3 scripts/get_locust_data.py ${TEST_DIR} ${LOCUST_SVC_URL} > /dev/null

    echo "Collecting worker response times file"
    ./scripts/get_response_time_worker.sh ${TEST_DIR} ${NAMESPACE}

    if [ ${HPA_CPU_ENABLED} = true ]
    then
        echo "Killing the HPA monitoring script"
        sudo kill -9 $(ps aux | grep hpa_monitor | grep -v grep | awk '{print $2}')
    fi

    if [ ${HPA_MEM_ENABLED} = true ]
    then
        echo "Killing the HPA Memory monitoring script"
        sudo kill -9 $(ps aux | grep hpa_mem_monitor | grep -v grep | awk '{print $2}')
    fi

    echo "Cleaning up setup."
    helm delete epi-bf -n ${NAMESPACE}
    helm delete locust -n ${NAMESPACE}
    kubectl delete configmap loadtest-locustfile -n ${NAMESPACE}
    kubectl delete configmap loadtest-lib -n ${NAMESPACE}

    echo "Collecting briding function stats"
    for NODE in ${WORKERS[@]}
    do
        bash scripts/get_pods_stats.sh ${TEST_DIR} ${NODE}
    done


    echo "Deleting old bridging function logs"
    for NODE in ${WORKERS[@]}
    do
        bash scripts/rm_pods_stats.sh ${NODE}
    done

    echo "Killing the Worker node monitoring script"
    sudo kill -9 $(ps aux | grep xen_vm_stats | grep -v grep | awk '{print $2}')

    echo "Test No. $TEST_NO is done, wait till all pods are terminated"

    while [[ $(kubectl get pods -n epi -o jsonpath='{.items}') != "[]" ]]
    do
         echo "Not all pods are terminated yet."
         sleep 2
    done

done

echo "All tests are done, generated data available in ${OUTPUT_DIR}"
