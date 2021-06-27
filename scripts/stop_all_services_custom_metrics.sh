cd metrics_gatherer/manifests/
./undeploy.sh
cd ../../


kubectl delete -f metrics_gatherer/bundle.yaml 
kubectl delete -f metrics_gatherer/prometheus-instance.yaml
kubectl delete -f metrics_gatherer/manifests


kubectl delete -f yamls/epi-configmap.yaml
kubectl delete -f yamls/epi-proxy.yaml
kubectl delete -f yamls/epi-server.yaml
#kubectl delete -f yamls/epi-vnf-firewall.yaml
kubectl delete -f yaml_generated/epi-proxy-custom-metrics-scaler.yaml

# Uninstall locust helm chart
helm delete locust -n epi
# Remove locust configmaps
kubectl delete configmap loadtest-locustfile -n epi
kubectl delete configmap loadtest-lib -n epi
#kubectl delete ns epi

