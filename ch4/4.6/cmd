
k apply -f _Lecture_k8s_learning.kit/ch4/4.6/sts-svc-domain-headless.yaml
k get po,svc 

k exec net -it -- /bin/bash
nslookup sts-svc-domain
[성공] 
nslookup sts-chk-hn-0.sts-svc-domain
nslookup sts-chk-hn-1.sts-svc-domain
nslookup sts-chk-hn-2.sts-svc-domain

k apply -f _Lecture_k8s_learning.kit/ch4/4.6/sts-no-answer-headless.yaml
k get po,svc 

k exec net -it -- /bin/bash
nslookup test
[실패]
nslookup sts-chk-hn-0.test
nslookup sts-chk-hn-1.test
nslookup sts-chk-hn-2.test

k apply -f _Lecture_k8s_learning.kit/ch4/4.6/sts-lb.yaml
k get po,svc 