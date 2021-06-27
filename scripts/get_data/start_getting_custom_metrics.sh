SVC_IP=$(kubectl get svc metrics-prom | tail -n 1 | awk '{print $3;}')
printf "" > "${1}/custom_metrics_requests_rate.txt"

while true; do
    DATA=$(curl -s http://${SVC_IP}:9090/api/v1/query?query=sum%28rate%28http_requests_total%7Bnamespace%3D%22epi%22%2Cservice%3D%22epi-proxy%22%7D%5B1m%5D%29%29+by+%28service%29 | jq '.data.result[0]')
    TIME=$(echo ${DATA} | jq '.value[0]')
    VALUE=$(echo ${DATA} | jq '.value[1]')
    echo "${TIME} ${VALUE}" >> "${1}/custom_metrics_requests_rate.txt"
    sleep 1
done
