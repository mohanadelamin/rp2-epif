#!/bin/bash
LAST_FILE=$(ls -1v get_data/data | tail -1)
INDEX=$((${LAST_FILE//[!0-9]/} + 1))
DIR_NAME="get_data/data/data_${INDEX}/"
mkdir ${DIR_NAME}


#############################################################################
# Start all services wait till they are ready

./start_all_services.sh
sleep 2



PORT_LOCUST=$(kubectl get svc locust | grep -Eo '8089:[0-9]*')

PORT_LOCUST_T=$(kubectl get svc locust | grep -Eo '8089:[0-9]*')

IFS=":"
read -ra array <<<"${PORT_LOCUST_T}"

for i in "${array[@]}";
do
echo "$i"
done;

PORT_LOCUST=${array[1]}

URL="http://localhost:${PORT_LOCUST}"
echo "URL: ${URL}"
STATUS_CODE=$(curl --silent --output /dev/stderr --write-out '%{http_code}' "${URL}")
echo "http://localhost:${PORT_LOCUST}"

echo "while loop res: ${STATUS_CODE}"

# Wait till locust is ready
while test "${STATUS_CODE}" != "200"; do
	echo "${URL}"
	STATUS_CODE=$(curl --silent --output /dev/stderr --write-out '%{http_code}' "${URL}")
	echo "while loop res: ${STATUS_CODE}"
        sleep 1
done

#############################################################################
# Start locust test


echo "Start locust request"
python3 locust_start_request.py 10 1

#############################################################################
# get data


echo "Get data"

./get_data/get_pim.sh ${DIR_NAME}
python3 get_data/get_locust_data.py ${DIR_NAME}


./get_data/remove_pim.sh
./stop_all_services.sh
