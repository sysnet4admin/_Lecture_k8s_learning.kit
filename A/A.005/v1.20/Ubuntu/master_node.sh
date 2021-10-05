#!/usr/bin/env bash

# Create config.yaml 
cat <<EOF > /tmp/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
bootstrapTokens:
- token: "123456.1234567890123456"
  description: "default kubeadm bootstrap token"
  ttl: "0"
localAPIEndpoint:
  advertiseAddress: 192.168.1.$1
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
clusterName: cluster-$2
networking:
  podSubnet: 172.16.0.0/16
EOF

# Fixed Internal-IP  
cat <<EOF > /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=192.168.1.$1
EOF

# init kubernetes from --config due to clusterName
kubeadm init --config=/tmp/kubeadm-config.yaml --upload-certs

# config for master node only 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# raw_address for gitcontent
raw_git="raw.githubusercontent.com/sysnet4admin/IaC/master/manifests" 

# config for kubernetes's network 
kubectl apply -f https://$raw_git/172.16_net_calico_v1.yaml

# Change context name from original to each cluster 
kubectl config rename-context kubernetes-admin@cluster-$2 $2

# Change user name from original to each cluster 
sed -i "s,kubernetes-admin,$2-admin,g" $HOME/.kube/config 
