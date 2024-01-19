#etcd backup and restore Backup 

ETCDCTL_API=3 etcdctl \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /tmp/etcd.bck

ETCDCTL_API=3 etcdctl --cert=/etc/kubernetes/pki/etcd/server.crt --cacert=/etc/kubernetes/pki/etcd/ca.crt --key=/etc/kubernetes/pki/etcd/server.key member list /tmp/etcd.bck

ETCDCTL_API=3 etcdctl --cert=/etc/kubernetes/pki/etcd/server.crt --cacert=/etc/kubernetes/pki/etcd/ca.crt --key=/etc/kubernetes/pki/etcd/server.key member list /tmp/etcd.bck

ETCDCTL_API=3 etcdctl --cert=/etc/kubernetes/pki/etcd/server.crt --cacert=/etc/kubernetes/pki/etcd/ca.crt --key=/etc/kubernetes/pki/etcd/server.key --write-out=table snapshot status /tmp/etcd.bck

Restore
ETCDCTL_API=3 etcdctl \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--initial-advertise-peer-urls=https://192.168.1.110:2380 \
--initial-cluster=bk8s-m=https://192.168.1.110:2380 \
--name=bk8s-m  \
--data-dir=/var/lib/etcd_backup \
snapshot restore /tmp/etcd.bck

ACTION: into etcd manifest and change hostpath from /var/lib/etcd to /var/lib/etcd_backup


# Schedule to specific node 

k run w2-pod --image=nginx --dry-run -o yaml > w2-pod.yaml
add nodeName in the manifest 


# Deploy application and expose

k create deploy nginx --image=nginx 
k scale deployment nginx --replicas=2
k expose deployment nginx --type=NodePort --port=80


# Deploy Pv,PVC

run before starting 

root@10cka-con:~# cat local-storage.yaml 
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

ssh root@bk8s-w1 mkdir -p /data/vol/pv

create pv,pvc 

root@10cka-con:~# cat pv-data.yaml 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /data/vol/pv  
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - bk8s-w1

root@10cka-con:~# cat pvc-data.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi


root@10cka-con:~# cat local-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: local-pod 
  labels:
    name: local-pod 
spec:
  containers:
  - name: sleepy 
    image: sysnet4admin/sleepy 
    volumeMounts:
      - name: local-persistent-storage
        mountPath: /data
  volumes:
    - name: local-persistent-storage
      persistentVolumeClaim:
        claimName: pvc-data


# Cluster malfunction

run before starting 
run.sh 
#!/usr/bin/env bash
ssh root@bk8s-w2 systemctl stop kubelet 
kubectl create deploy mal-app --image=nginx 
kubectl scale deploy mal-app --replicas=4

fix kubelet issue 
