#!/bin/bash

# Usage
# ./get_response_time_worker.sh <DIR> <NAMESPACE>

for pod in `kubectl get pods -n $2 --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`; do
    if [[ ${pod} == locust-worker* ]];
    then 
	    kubectl -n $2 cp ${pod}:/mnt/response_times $1/response_times
    fi
done