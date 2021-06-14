# sudo -u root kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts
# ssh -L 50000:145.100.106.194:30999 root@145.100.106.194

cd manifests/
./gencerts.sh
./deploy.sh
cd ../
kubectl apply -f bundle.yaml 
kubectl apply -f prometheus-instance.yaml
kubectl apply -f manifests

kubectl apply -f epi-configmap.yaml 
kubectl apply -f ../../yamls/epi-client.yaml
kubectl apply -f ../../yamls/epi-server.yaml
kubectl apply -f epi-proxy-custom-metrics-scaler.yaml

#https://github.com/kubernetes-sigs/prometheus-adapter/issues/164