[root@m-k8s ~]# kubectl get node m-k8s -o yaml | nl | grep  taints -F3
    24    podCIDR: 172.16.0.0/24
    25    podCIDRs:
    26    - 172.16.0.0/24
    27    taints:
    28    - effect: NoSchedule
    29      key: node-role.kubernetes.io/master
    30  status:

===
kubectl taint nodes w3-k8s DB=customer-info:NoSchedule

kubectl taint nodes w3-k8s DB=customer-info:NoSchedule-


