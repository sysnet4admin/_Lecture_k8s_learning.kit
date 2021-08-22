deploy and scale

watch kubectl get pods

 
[root@m-k8s ~]# k scale statefulset sts-chk-hn --replicas=10
statefulset.apps/sts-chk-hn scaled
[root@m-k8s ~]# k scale statefulset sts-chk-hn --replicas=3
statefulset.apps/sts-chk-hn scaled

