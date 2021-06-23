for pod in `kubectl get pods -n $2 --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`; do
    if [[ ${pod} == locust-worker* ]];
    then 
<<<<<<< HEAD
	    kubectl -n $2 cp ${pod}:/mnt/response_times $1/response_times
=======
	    kubectl cp -n epi ${pod}:/mnt/response_times $1/response_times 
>>>>>>> 4f61733c7ffed4311594a6b02593c8e3a01ad3d8
    fi
done
