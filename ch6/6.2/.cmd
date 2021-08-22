k cordon w3-k8s 
k apply -f deploy-drain.yaml
k get po 
k get node
k deletle deploy deploy-drain 
k uncordon w3-k8s 

error: cannot delete Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet (use --force to override): default/net


k apply -f deploy-drain.yaml
k drain w3-k8s
k drain w3-k8s --ignore-daemonsets
k drain w3-k8s --ignore-daemonsets --force 
k get node
k uncordon w3-k8s
k get node
k delete -f deploy-drain.yaml
