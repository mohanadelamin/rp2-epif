#!/bin/bash
LAST_FILE=$(ls -1v get_data/data | tail -1)
INDEX=$((${LAST_FILE//[!0-9]/} + 1))
DIR_NAME="get_data/data/data_${INDEX}/"
NUMBER_OF_USERS=1
SPAWN_RATE=5
RUN_TIME=30

mkdir ${DIR_NAME}

sudo docker image rm pimpaardekooper/vnf_instances:locust_worker

############################################################################
#epi-bf-hpa
BF_HPA_MIN_REPLICAS=1
BF_HPA_UTILIZATION=30
BF_HPA_MAX_REPLICAS=1
BF_HPA_SCALABLE_RESOURCE=cpu


#epi-bf
BF_LIMITS_CPU="100m"
BF_LIMITS_MEM="500Mi"
BF_REQUEST_CPU="50m"
BF_REQUEST_MEM="100Mi"

# client
CLIENT_LIMITS_CPU="1300m"
CLIENT_LIMITS_MEM="500Mi"
CLIENT_REQUEST_CPU="200m"
CLIENT_REQUEST_MEM="100Mi"

#epi-server
SERVER_REPLICAS=1
SERVER_LIMITS_CPU="300m"
SERVER_LIMITS_MEM="500Mi"
SERVER_REQUEST_CPU="100m"
SERVER_REQUEST_MEM="100Mi"

#epi-proxy
PROXY_REPLICAS=1
PROXY_LIMITS_CPU="1300m"
PROXY_LIMITS_MEM="500Mi"
PROXY_REQUEST_CPU="500m"
PROXY_REQUEST_MEM="100Mi"

#############################################################################
# Start all services wait till they are ready

# Create config files, IMPORTANT dot before /make_yamls.sh give variables
cd yaml_configurable/ && . ./make_yamls.sh && cd ../
# Create environment with generated yamls
. ./experiment_start_all_services.sh
sleep 2



PORT_LOCUST_T=$(kubectl get svc locust | grep -Eo '8089:[0-9]*')
echo "PORT_LOCUST T: ${PORT_LOCUST_T}"
IFS=":"
read -ra local_p_public_p <<<"${PORT_LOCUST_T}"

for i in "${local_p_public_p[@]}";
do
echo "$i"
done;

PORT_LOCUST=${local_p_public_p[1]}

URL="http://localhost:${PORT_LOCUST}"
echo "URL: ${URL}"
STATUS_CODE=$(curl --silent --max-time 3 --output /dev/stderr --write-out '%{http_code}' "${URL}")
echo "http://localhost:${PORT_LOCUST}"

echo "while loop res: ${STATUS_CODE}"

# Wait till locust is ready
while test "${STATUS_CODE}" != "200"; do
	echo "${URL}"
	STATUS_CODE=$(curl --max-time 3 --silent --output /dev/stderr --write-out '%{http_code}' "${URL}")
	echo "while loop res: ${STATUS_CODE}"
        sleep 2
done

#############################################################################
# Start locust test


echo "Start locust request"
python3 locust_start_request.py ${NUMBER_OF_USERS} ${SPAWN_RATE}

timer=0
while [[ ${timer} -lt ${RUN_TIME} ]];
do
	echo "progress: ${timer}/${RUN_TIME}"
	((timer++))
	# add 1 user each second
	# NUMBER_OF_USERS=$((${NUMBER_OF_USERS}+5))
	echo "${NUMBER_OF_USERS}"
	python3 locust_start_request.py ${NUMBER_OF_USERS} ${SPAWN_RATE}
	sleep 1
done;

#############################################################################
# get data


echo "Get data"

./get_data/get_pim.sh ${DIR_NAME}
./get_data/get_monitoring_data.sh ${DIR_NAME}
python3 get_data/get_locust_data.py ${DIR_NAME} > /dev/null
# Write milicore allocated.
echo "${BF_LIMITS_CPU},${BF_REQUEST_CPU},${BF_LIMITS_MEM},${BF_REQUEST_MEM}" > "${DIR_NAME}/bf_milicore.txt"
echo "${SERVER_LIMITS_CPU},${SERVER_REQUEST_CPU},${SERVER_LIMITS_MEM},${SERVER_REQUEST_MEM}" >> "${DIR_NAME}/bf_milicore.txt"
echo "${PROXY_LIMITS_CPU},${PROXY_REQUEST_CPU},${PROXY_LIMITS_MEM},${PROXY_REQUEST_MEM}" >> "${DIR_NAME}/bf_milicore.txt"
echo "${CLIENT_LIMITS_CPU},${CLIENT_REQUEST_CPU},${CLIENT_LIMITS_MEM},${CLIENT_REQUEST_MEM}" >> "${DIR_NAME}/bf_milicore.txt"


./get_data/remove_pim.sh
./stop_all_services.sh
