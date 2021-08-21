k apply -f deploy-4-hpa.yaml 
k autoscale deployment deploy-4-hpa --min=1 --max=10 --cpu-percent=50
k get hpa
watch kubectl top pods --use-protocol-buffers 
k delete 
