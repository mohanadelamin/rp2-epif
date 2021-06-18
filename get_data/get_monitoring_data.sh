for pod in `kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`; do
	kubectl cp ${pod}:/data/. $1
done

