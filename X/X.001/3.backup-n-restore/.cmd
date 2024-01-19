# etcd backup 

controlplane $ vi /etc/kubernetes/manifests/etcd.yaml 

ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  snapshot save /tmp/etcd-backup.db

controlplane $ k delete ns application1

# etcd restore  

ETCDCTL_API=3 etcdctl \
  --data-dir /var/lib/etcd-new \
  snapshot restore /tmp/etcd-backup.db 

controlplane $ vi /etc/kubernetes/manifests/etcd.yaml 

controlplane $ cat /etc/kubernetes/manifests/etcd.yaml | grep etcd-new -C3
    - --advertise-client-urls=https://172.30.1.2:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --client-cert-auth=true
    - --data-dir=/var/lib/etcd-new                       <<<
    - --experimental-initial-corrupt-check=true
    - --experimental-watch-progress-notify-interval=5s
    - --initial-advertise-peer-urls=https://172.30.1.2:2380
--
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /var/lib/etcd-new                       <<<
      name: etcd-data-new                                <<<
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
--
      type: DirectoryOrCreate
    name: etcd-data
  - hostPath:
      path: /var/lib/etcd-new                            <<<
      type: DirectoryOrCreate
    name: etcd-data-new                                  <<<
