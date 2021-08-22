k apply -f ~/_Lecture_k8s_learning.kit/ch4/4.7/loadbalancer.yaml

k get svc
k get endpoints

k apply -f ~/_Lecture_k8s_learning.kit/ch4/4.7/service-endpoints.yaml

k get svc 
k get endpoints

[root@m-k8s ~]# k exec net -it -- /bin/bash
[root@net /]# curl external-data
request_method : GET | ip_dest: 172.16.132.4

