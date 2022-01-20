#!/usr/bin/env bash

# update package list 
apt update 

# install docker 
apt install -y docker-ce=$2 docker-ce-cli=$2 containerd.io=$3

# install kubernetes
# both kubelet and kubectl will install by dependency
# but aim to latest version. so fixed version by manually
apt install -y kubelet=$1 kubectl=$1 kubeadm=$1

# Ready to install for k8s 
systemctl enable --now docker
systemctl enable --now kubelet

# docker daemon config for systemd from cgroupfs & restart 
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload && systemctl restart docker
