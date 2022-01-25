# keta install
kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.5.0/keda-2.5.0.yaml

k apply -f keda-frontend.yaml 
watch kubectl get po -l app=keda-frontend

k apply -f keda-backend.yaml 
watch kubectl get po -l app=keda-backend

k get deploy 

# modify time to now or in few minutes 
k apply -f keda-backend-scaledobject.yaml 

# wait for cron / pod from 1 to 2 by cron 

# few minutes later. Run this and wait for backend follow up. 
k scale deployment keda-frontend --replicas=7

# optional 
k scale deployment keda-frontend --replicas=1
 
# keta uninstall 
kubectl delete -f https://github.com/kedacore/keda/releases/download/v2.5.0/keda-2.5.0.yaml



