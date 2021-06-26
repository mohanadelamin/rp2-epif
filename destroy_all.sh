#!/bin/bash
# Destroy EPI PoC Helm
helm delete epi-bf -n epi

# Locust test script
kubectl delete configmap loadtest-locustfile -n epi
kubectl delete configmap loadtest-lib -n epi

# Destroy Locust distrubtuted load tester
helm delete locust -n epi\

WORKERS=("145.100.110.91" "145.100.110.92")
echo "Deleting old bridging function logs"
for NODE in ${WORKERS[@]}
do
    bash scripts/rm_pods_stats.sh ${NODE}
done