
# analyze missing deployment 

## run 
k8sgpt analyze 
## deploy deploy+loadbalancer
k apply -f ch4/4.4/loadbalancer-11.yaml
## delete lb 
k delete deploy deploy-nginx
## run again 
k8sgpt analyze 

# analyze missing configmap 
## deploy deploy+configmap  
k apply -f ch9/9.2/deploy-configMapRef.yaml
k apply -f ch9/9.2/ConfigMap-sleepy-config.yaml
## delete configmap 
k delete cm sleepy-config 
## run 
k8sgpt analyze 


