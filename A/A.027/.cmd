# 1.kubectl replace 
# deploy nginx nginx --image=nginx 
k create deploy nginx --image=nginx 

# failure due to not enough information 
kubectl replace -f fail-replace-change-image.yaml

# success due to full content in 
kubectl replace -f succ-replace-change-image.yaml

# partly success with warning annotation  
kubectl applyf -f succ-replace-change-image.yaml

# how about this case which already deployed 
# k get deploy nginx -o yaml | sed 's|\(image: nginx\)|image: httpd|' | kubectl apply -f -
# Warning: resource deployments/nginx is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
# deployment.apps/nginx configured
# k get deploy nginx -o json | jq '.spec.template.spec.containers[0].image = "httpd"' | kubectl apply -f -
# Warning: resource deployments/nginx is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
# deployment.apps/nginx configured

# thus 
k get deploy nginx -o yaml | sed 's|\(image: nginx\)|image: httpd|' | kubectl replace -f -
k get deploy nginx -o json | jq '.spec.template.spec.containers[0].image = "httpd"' | kubectl replace -f -

# 2.kubectl patch 
# deploy nginx deployment  
k create deploy nginx --image=nginx 

# change replica numbers 
kubectl patch deployment nginx -p '{"spec": {"replicas": 3}}'
kubectl patch deployment nginx -p '{"spec": {"replicas": null}}'
kubectl patch deployment nginx -p '{"spec": {"replicas": 0}}'
kubectl patch deployment nginx --patch-file patch-to-replica-6.yaml

# if there is no options, it has been shown like this. 
# [root@m-k8s ~]# kubectl patch deployment nginx '{"spec": {"replicas": 3}}'
# error: must specify --patch or --patch-file containing the contents of the patch

kubectl patch configmaps -n metallb-system config --patch-file patch-metallb-config-ip99.yaml

# three type: [strategic(default), merge, json] 
# merge is more radical changement support like null value's key will be removed 
# https://www.disasterproject.com/kubernetes-kubectl-patching/

# type: strategic (default)
kubectl patch deployment nginx --type="strategic" --patch-file patch-to-add-container.yaml --dry-run=client -o yaml

# type: merge 
kubectl patch deployment nginx --type="merge" --patch-file patch-to-add-container.yaml --dry-run=client -o yaml

# type: json 
# change image with just -p 
kubectl patch deployment nginx -p'{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"httpd"}]}}}}'

# if merge key doesn't have?
# [root@m-k8s ~]# kubectl patch deployment nginx -p'{"spec":{"template":{"spec":{"containers":[{"image":"httpd"}]}}}}'
# Error from server: map: map[image:httpd] does not contain declared merge key: name

# op: operations = replace 
kubectl patch deployment nginx  --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value":2}]'
kubectl patch deployment nginx  --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"sysnet4admin/chk-ip"}]'

# op: operations = add 
kubectl patch deployment nginx  --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/1/image", "value":"redis"}]'

# op: operations = remove 
kubectl patch deployment nginx  --type='json' -p='[{"op": "remove", "path": "/spec/replicas", "value":2}]'


