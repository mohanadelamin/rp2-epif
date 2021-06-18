# Create epi namespace
#kubectl create ns epi
# Add config map for environment variables.


kubectl apply -f yamls/epi-configmap.yaml
# Deploy the socks5 proxy
kubectl apply -f yamls/epi-proxy.yaml
# Deploy the httpbin server
kubectl apply -f yamls/epi-server.yaml
# Deploy the bridging function
kubectl apply -f yamls/epi-bf.yaml
# Deploy the bridging function HPA
kubectl apply -f yamls/epi-bf-hpa.yaml
# Deploy Locust helm chart to repo
helm repo add deliveryhero https://charts.deliveryhero.io/
# Locust test script
kubectl create configmap loadtest-locustfile --from-file locust-test/main.py  -n epi
kubectl create configmap loadtest-lib --from-file locust-test/lib/ -n epi
# Deploy Locust distrubtuted load tester 
helm install locust deliveryhero/locust -n epi --set service.type="NodePort" \
--set loadtest.name=epif-bf-loadtest \
--set securityContext.privileged=true \
--set worker.image="pimpaardekooper/vnf_instances:locust_worker" \
--set worker.imagePullPolicy="always" \
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
