#!/bin/bash

# Deploy EPI PoC Helm
helm repo add epi-helm https://mohanadelamin.github.io/epi-bf-helm/
helm install epi-bf epi-helm/epi_bf_helm -n epi \
--set bf.image="melamin/epi_vnf_firewall:v0.0.7" \
--set bf.cpu_limit="500m" \
--set bf.mem_limit="500Mi" \
--set bf_hpa.maxReplicas="5" \
--set 


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
