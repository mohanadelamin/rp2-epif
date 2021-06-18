#!/bin/bash
# Destroy EPI PoC Helm
helm delete epi-bf -n epi

# Locust test script
kubectl delete configmap loadtest-locustfile -n epi
kubectl delete configmap loadtest-lib -n epi

# Destroy Locust distrubtuted load tester
helm delete locust -n epi\