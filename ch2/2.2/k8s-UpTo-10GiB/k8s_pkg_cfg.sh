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

# Ready to install for k8s 
systemctl enable --now docker
systemctl enable --now kubelet
