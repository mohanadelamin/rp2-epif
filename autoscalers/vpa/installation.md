# prerequisites
- Deploy metric server: https://github.com/kubernetes-sigs/metrics-server
```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
- openssl to version 1.1.1 or higher
```shell
apt install openssl
```


- Remove previous installation
```shell
./hack/vpa-down.sh
```

# Installation
```shell
git clone https://github.com/kubernetes/autoscaler.git
.vertical-pod-autoscaler/hack/vpa-up.sh
```

Note: If you are seeing following error during this step:
```
unknown option -addext
```
please upgrade openssl to version 1.1.1 or higher (needs to support -addext option) or use ./hack/vpa-up.sh on the [0.8 release branch](https://github.com/kubernetes/autoscaler/tree/vpa-release-0.8).

# Limitations
- VPA recommendation might exceed available resources (e.g. Node size, available size, available quota) and cause pods to go pending. This can be partly addressed by using VPA together with Cluster Autoscaler.