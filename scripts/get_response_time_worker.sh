for pod in `kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`; do
    if [[ ${pod} == locust-worker* ]];
    then 
	    kubectl cp ${pod}:/mnt/response_times $1/response_times
    fi
done
