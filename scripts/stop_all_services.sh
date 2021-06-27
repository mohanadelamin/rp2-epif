kubectl delete -f yamls/epi-configmap.yaml
kubectl delete -f yamls/epi-proxy.yaml
kubectl delete -f yamls/epi-server.yaml
#kubectl delete -f yamls/epi-vnf-firewall.yaml
kubectl delete -f yamls/epi-bf.yaml
kubectl delete -f yamls/epi-bf-hpa.yaml
# Uninstall locust helm chart
helm delete locust -n epi
# Remove locust configmaps
kubectl delete configmap loadtest-locustfile -n epi
kubectl delete configmap loadtest-lib -n epi
#kubectl delete ns epi