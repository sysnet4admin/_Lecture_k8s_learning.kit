

# pod limit to 10 

[root@m-k8s 8.7]# k logs -n kube-system kube-controller-manager-m-k8s | tail
E0704 11:50:45.487696       1 replica_set.go:532] sync "dev1/nginx-6799fc88d8" failed with pods "nginx-6799fc88d8-jmg49" is forbidden: exceeded quota: dev1-quota, requested: pods=1, used: pods=10, limited: pods=10
I0704 11:50:45.488072       1 event.go:291] "Event occurred" object="dev1/nginx-679

or 

[root@m-k8s ~]# k describe replicasets.apps -n dev1 quota-pod11-failure-7fc88499c7
  Normal   SuccessfulCreate  13m                   replicaset-controller  Created pod: quota-pod11-failure-7fc88499c7-w9wwq
  Normal   SuccessfulCreate  13m                   replicaset-controller  Created pod: quota-pod11-failure-7fc88499c7-g2wkd
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-26449" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Normal   SuccessfulCreate  13m                   replicaset-controller  Created pod: quota-pod11-failure-7fc88499c7-6jgd5
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-hr5c5" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Normal   SuccessfulCreate  13m                   replicaset-controller  (combined from similar events): Created pod: quota-pod11-failure-7fc88499c7-lt5mn
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-ch6sd" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-7sq2m" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-7kjnt" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-vxjtn" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-mqcd5" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-2hxfp" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Warning  FailedCreate      13m                   replicaset-controller  Error creating: pods "quota-pod11-failure-7fc88499c7-nn25q" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10
  Warning  FailedCreate      8m26s (x38 over 13m)  replicaset-controller  (combined from similar events): Error creating: pods "quota-pod11-failure-7fc88499c7-8krb2" is forbidden: exceeded quota: quota-dev1, requested: pods=1, used: pods=10, limited: pods=10




k delete resourcequotas -n dev1 quota-dev1
