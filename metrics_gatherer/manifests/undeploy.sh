kubectl delete -f custom-metrics-apiserver-auth-delegator-cluster-role-binding.yaml
kubectl delete -f custom-metrics-apiserver-auth-reader-role-binding.yaml
kubectl -n custom-metrics delete -f cm-adapter-serving-certs.yaml
kubectl -n custom-metrics delete -f custom-metrics-apiserver-deployment.yaml
kubectl delete -f custom-metrics-apiserver-resource-reader-cluster-role-binding.yaml
kubectl -n custom-metrics delete -f custom-metrics-apiserver-service-account.yaml
kubectl -n custom-metrics delete -f custom-metrics-apiserver-service.yaml
kubectl delete -f custom-metrics-apiservice.yaml
kubectl delete -f custom-metrics-cluster-role.yaml
kubectl delete -f custom-metrics-resource-reader-cluster-role.yaml
kubectl delete -f hpa-custom-metrics-cluster-role-binding.yaml