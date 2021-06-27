# epi-bf-helm

A chart to deploy the required nodes for testing Bridging function scaling for the EPI Framework. The chart files are maintained on this [repo](https://github.com/mohanadelamin/epi-bf-helm)

The chart will deploy the following topology (Without the locust load generator)
![setup](https://raw.githubusercontent.com/mohanadelamin/epi-bf-helm/main/Setup.png)

Installation example:
```console
helm repo add epi-helm https://mohanadelamin.github.io/epi-bf-helm/
helm install epi-bf epi-helm/epi_bf_helm
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bf.image | string | melamin/epi_vnf_firewall:v0.0.7 | Bridging function image |
| bf.cpu_limit | string | 500m | |
| bf.mem_limit | string | 500Mi | |
| bf.cpu_request | string | 200m | |
| bf.mem_request | string | 100Mi | |
| bf_hpa.cpu_enabled | bool | true | |
| bf_hpa.mem_enabled | bool | false | |
| bf_hpa.minReplicas | int | 1 | |
| bf_hpa.maxReplicas | int | 5 | |
| bf_hpa.cpu_averageUtilization | int | 30 | |
| bf_hpa.mem_averageUtilization | int | 30 | |
| bf_custom_hpa.enabled | bool | false | |
| bf_custom_hpa.minReplicas | int | 1 | |
| bf_custom_hpa.maxReplicas | int | 5 | |
| bf_custom_hpa.metricName | string | http_requests | |
| bf_custom_hpa.targetValue | string | 15000m | |
| proxy.image | string | melamin/epi_proxy:v0.0.3 | |
| server.image | string | melamin/httpbin:v0.0.1 | |
| other_vars.EPI_SERVER | string | epi-server | |
| other_vars.EPI_SERVER_PORT | int | 80 | |
| other_vars.EPI_VNF | string | epi-bf | |
| other_vars.EPI_VNF_PORT | int | 5000 | |
| other_vars.PROXY_HOST | string | epi-proxy| |
| other_vars.PROXY_PORT| int | 1080 | |
| other_vars.DELTA | string | 5.0 | |

# Maintainers
| Name | Email | Url |
| ---- | ------ | --- |
| Mohanad Elamin| melamin@os3.nl |  |
| Pim Paardekooper| ppaardekooper@os3.nl|  |