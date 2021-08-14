k run nginx --image=nginx 
k get pod
k create deployment nginx --image=nginx 
k scale deployment nginx --replicas=3 
k get pods 
k delete pod nginx 
k delete deployment nginx 

k apply -f ~/_Lecture_k8s_learning.kit/ch2/2.3/apy-nginx.yaml 
k exec apy-nginx-<replica>-<HASH> -it -- /bin/bash  
k edit > replicas=1
k delete deployment apy-nginx 
