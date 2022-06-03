kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/" | jq

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/" | jq | grep pods
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/namespaces/default/pods/*/memory_max_usage_bytes" | jq

k delete po -n custom-metrics -l app=custom-metrics-apiserver
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/namespaces/default/pods/*/nginx_http_requests_per_second" | jq




