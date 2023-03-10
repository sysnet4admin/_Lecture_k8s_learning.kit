
k get node 

kubectl apply -f nodename.yaml 
k get po -o wide 

cat nodename.yaml | grep nodeName
k port-forward --address 0.0.0.0 nodename 80:80
