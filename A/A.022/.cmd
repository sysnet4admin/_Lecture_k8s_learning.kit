kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/" | jq

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/namespaces/default/pods/*/nginx_http_requests_per_second" | jq




