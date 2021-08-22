kubectl get pods -o wide  --sort-by=.spec.nodeName

k apply -f w1-affinity-leader.yaml 
k apply -f deployment-podAffinity
k apply -f w3-affinity-leader.yaml 

k scale deploy deploy-podaffinity --replicas=1
k scale deploy deploy-podaffinity --replicas=4

k apply -f deployment-anti-podAffinity.yaml

