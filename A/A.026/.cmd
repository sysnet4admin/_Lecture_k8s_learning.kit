# kubectl apply -f (partly failure)
k apply -f prometheus-operator.yaml
k delete -f prometheus-operator.yaml

# kubectl create -f (success) 
k create -f prometheus-operator.yaml
k delete -f prometheus-operator.yaml

# kubectl apply -f (success) --server-side
k create -f prometheus-operator.yaml --server-side
k delete -f prometheus-operator.yaml


