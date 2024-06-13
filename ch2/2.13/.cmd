k run nginx --image=nginx -o yaml 
k delete pod nginx 

k run nginx --image=nginx -o yaml --dry-run=client
k run nginx --image=nginx -o yaml --dry-run=client > po-nginx.yaml 
cat po-nginx.yaml 
k apply -f po-nginx.yaml 
k get pod 
k delete pod nginx 

k create deployment nginx --image=nginx -o yaml --dry-run=client > deploy-nginx.yaml
cat deploy-nginx.yam
vi > replicas=3
k apply -f deploy-nginx.yaml 
k delete -f deploy-nginx.yaml  
