#!/usr/bin/env bash

# install util packages 
yum install epel-release -y
yum install vim-enhanced -y
yum install git -y

# install docker 
yum install docker-ce-$2 docker-ce-cli-$2 containerd.io-$3 -y

# install kubernetes
# both kubelet and kubectl will install by dependency
# but aim to latest version. so fixed version by manually
yum install kubelet-$1 kubectl-$1 kubeadm-$1 -y 

# containerd configure to  default
containerd config default > /etc/containerd/config.toml

# Fixed container runtime to containerd
cat <<EOF > /etc/default/kubelet
KUBELET_KUBEADM_ARGS=--container-runtime=remote \
                     --container-runtime-endpoint=/run/containerd/containerd.sock \
                     --cgroup-driver=systemd
EOF

# Avoid WARN&ERRO(default endpoints) when crictl run  
cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF

# Ready to install for k8s 
systemctl enable --now docker
systemctl enable --now containerd
systemctl enable --now kubelet
