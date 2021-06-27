# rp2-epif

This repo contains the scripts required to test autoscaling of the containerized bridging functions for the EPI framework. 


The following is the setup topology that can be deployed using helm charts:
![setup](https://raw.githubusercontent.com/mohanadelamin/epi-bf-helm/main/Setup.png)

To deploy the setup two helm charts is used:
1. [epi-bf-helm](https://github.com/mohanadelamin/epi-bf-helm): A Helm chart to deploy the Bridging function, Proxy, web server, and the corresponding Kubernetes services.
2. [Locust](https://github.com/deliveryhero/helm-charts/tree/master/stable/locust): A Helm chart to deploy the locust load generator. (The test file for locust is available under the locust-test directory)

The details of each Helm chart are available on its repository. 

To deploy the setup the following script can be used. Which will use the two helm chart above
```console
bash scripts/build_all.sh
```

To destroy the setup the following script can be used:
```console
bash scripts/destroy_all.sh
```

Automated testing can be performed as per the following workflow:
![setup_Automation](https://raw.githubusercontent.com/mohanadelamin/rp2-epif/main/Testing_setup.png)

1. The test use cases are saved to the usecases_test_vars.csv which contains. different users, spawnrate, test duriation, HPA threshold, CPU Limit, and memory limit. 
2. The scripts/run_expermiments.sh script read the use cases csv and trigger the setup deployment as per the vales.
3. The script will call the two helm chart mentioned above and deploy the setup.
4. The run_expermiments.sh will call locust_start_request.py script to trigger locust to start the test. 
5. The deployed images contain a metric script that collect memory and cpu usage of the deployed pods. while the following scripts will be running on the test machine to collect data from the setup:
    1. scripts/hpa_monitor.sh: A script to monitor the CPU Horizontal Pod Autoscaller utilization and number of replicas.
    2. scripts/hpa_mem_monitor.sh: A script to monitor the Memory Horizontal Pod Autoscaller utilization and number of replicas.
    3. scripts/xen_vm_stats.py: A script to monitor the Virtual machines that hosting the K8S worker nodes.
6. After the end of the test the run_experiments.sh will trigger the following script to collect the data and clean up old logs:
    1. scripts/get_pods.stats.sh: A script to scp the stats files from the worker nodes.
    2. scripts/get_locsut_data.py: A script to retrive the stats from locust load generator.
    3. scripts/get_response_time_worker.sh: A script to retrive the response time data from locust worker.
    4. scripts/rm_pods_stats.sh: A script to delete old log files to clean up the setup for new test.
7. Finally the collected data can be plotted.

The script will loop through all the test use cases defined in the use case csv file.

## Images:
The images used for the deployment are the following (Available under the images directory):
1. firewall-node: A basic firewalling bridging function.
2. http_filter: A basic Layer 7 inspection bridging function.
3. network_monitoring: A basic network monitoring bridging function.
4. proxy-node: A sock5 proxy node that redirect the traffic to the bridging function.
5. server-node: A [httpbin](https://httpbin.org/) server.
6. locust-worker: A modified locust worker image to include a sock5 redirector process, to redirect the testing traffic to the sock5 proxy.


## Disclaimer

These containts of this repository are supplied "AS IS" without any warranties and support.