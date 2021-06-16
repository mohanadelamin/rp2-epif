cd manifests/
./undeploy.sh
cd ../
kubectl delete -f bundle.yaml 
kubectl delete -f prometheus-instance.yaml
kubectl delete -f manifests

kubectl delete -f epi-configmap.yaml 
kubectl delete -f ../yamls/epi-client.yaml
kubectl delete -f ../yamls/epi-server.yaml
kubectl delete -f epi-proxy-custom-metrics-scaler.yaml
