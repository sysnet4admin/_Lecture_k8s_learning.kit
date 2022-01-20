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

# install etctctl 
curl -L  https://github.com/sysnet4admin/BB/raw/main/etcdctl/v3.4.15/etcdctl -o /usr/local/bin/etcdctl
chmod 744 /usr/local/bin/etcdctl 

# Change context name from original to each cluster 
kubectl config rename-context kubernetes-admin@cluster-$2 $2

# Change user name from original to each cluster 
sed -i "s,kubernetes-admin,$2-admin,g" $HOME/.kube/config 

# alias kubectl to k (for cks)
echo 'alias k=kubectl' >> ~/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo "alias kd='kubectl delete -f'" >> ~/.bashrc

echo 'source <(kubectl completion bash)' >> ~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'complete -F __start_kubectl k' >> ~/.bashrc