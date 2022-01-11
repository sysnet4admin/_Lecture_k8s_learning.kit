# deploy reloader 
kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml

# deploy secrets 
secrets

# deploy deployment 
deploy-secretKeyRef-reloader

# edit secrets 
k edit secrets mysql-cred
