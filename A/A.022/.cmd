cd _Lecture_k8s_learning.kit/A/A.022
./0-1.pre-install-prometheus.sh
k get po,svc -n monitoring

./0-2.pre-custom-metrics.sh

kubectl api-versions 
./1.custom-metrics-w-pa.sh 
# check custom.metrics
kubectl api-versions 

# but pod could not deploy properly 
k get po -n custom-metrics
k describe po -n custom-metrics

k apply -f 2.custom-metrics-sample-cm.yaml
k get po -n custom-metrics
kubectl get --raw "/apis/custom.metrics.k8s.io/" | jq
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/" | jq
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/" | jq | grep pods
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/namespaces/default/pods/*/memory_max_usage_bytes" | jq

./3.pod-adapters-plus-annotation.sh
k get po,svc
curl <POD-IP>:9113/metrics

k apply -f 4.nginx_http_requests_per_second-cm.yaml
k delete po -n custom-metrics -l app=custom-metrics-apiserver
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/" | jq
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta2/namespaces/default/pods/*/nginx_http_requests_per_second" | jq

k apply -f 5.hpa-custom-metrics.yaml 
k get hpa 

./6.curl-get.sh 192.168.1.12
# from other terminal 
watch kubectl get hpa,deploy




