# 노드 w4-k8s 추가부터 필요 

k apply -f  _Lecture_k8s_learning.kit/ch7/7.9/deployment-topologyspreadconstraints.yaml
k get po -o wide 
k delete -f  _Lecture_k8s_learning.kit/ch7/7.9/deployment-topologyspreadconstraints.yaml

k apply -f _Lecture_k8s_learning.kit/ch7/7.9/deploy12-load-w3.yaml
k get po -o wide 
k apply -f  _Lecture_k8s_learning.kit/ch7/7.9/deployment-topologyspreadconstraints.yaml
k get po -o wide 
# Check distributed status.
# Okay?

k delete -f _Lecture_k8s_learning.kit/ch7/7.9/deploy12-load-w3.yaml
k delete -f  _Lecture_k8s_learning.kit/ch7/7.9/deployment-topologyspreadconstraints.yaml

# 노드 w4-k8s 삭제 필요 
k delete node w4-k8s 