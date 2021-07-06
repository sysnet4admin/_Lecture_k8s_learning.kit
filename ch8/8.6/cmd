

# pod limit to 10 

[root@m-k8s 8.7]# k logs -n kube-system kube-controller-manager-m-k8s | tail
E0704 11:50:45.487696       1 replica_set.go:532] sync "dev1/nginx-6799fc88d8" failed with pods "nginx-6799fc88d8-jmg49" is forbidden: exceeded quota: dev1-quota, requested: pods=1, used: pods=10, limited: pods=10
I0704 11:50:45.488072       1 event.go:291] "Event occurred" object="dev1/nginx-679
