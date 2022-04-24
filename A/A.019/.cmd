watch kubectl top node 
watch kubectl get deploy 

k apply -f _Lecture_k8s_learning.kit/A/A.019/pod-cnt110.yaml
k get po -o wide 
k scale deploy pod-cnt110 --replicas=10
.... (if you have fully enough computer, directly to the 110 pods)
k scale deploy pod-cnt110 --replicas=20
....30 40 50 60 70 80 90 100 
k scale deploy pod-cnt110 --replicas=110
watch kubectl get deploy
k get po -A -o wide --field-selector spec.nodeName=w3-k8s | grep Running | wc -l 
