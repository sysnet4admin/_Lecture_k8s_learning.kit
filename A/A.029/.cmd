# Minikube
## deploy minikube m1 + w2 
minikube start --force --driver=docker --nodes 3

## deploy pod & expose service on minikube
k create deploy nginx --image nginx --replicas=2
k expose po nginx --type=LoadBalancer --port=80
minikube tunnel 

## node management 
minikube node add
minikube ssh --node minikube-m04
docker ps
minikube node stop minikube-m03 # pod evict is not working 

# KWOK
## add node and delete node easily 
k get node 
k delete -f add-9-bulk-nodes-w-taints.yaml
k get node 
k apply -f add-9-bulk-nodes-w-taints.yaml

## apply node w3 directly 
cat nodename.yaml | grep nodeName
kubectl apply -f nodename.yaml 
k get po -o wide 

## expose pod 
k port-forward --address 0.0.0.0 nodename 80:80

## docker 
docker ps 
