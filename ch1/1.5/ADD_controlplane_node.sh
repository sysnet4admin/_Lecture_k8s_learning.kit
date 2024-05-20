#!/usr/bin/env bash

# init kubernetes (w/ containerd)
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
             --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.1.10 \
             --cri-socket=unix:///run/containerd/containerd.sock

# config for master node only 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# CNI raw address & config for kubernetes's network 
CNI_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/CNI"
kubectl apply -f $CNI_ADDR/172.16_net_calico_v3.26.0.yaml

# extended k8s certifications all
git clone https://github.com/yuyicai/update-kube-cert.git /tmp/update-kube-cert
chmod 755 /tmp/update-kube-cert/update-kubeadm-cert.sh
/tmp/update-kube-cert/update-kubeadm-cert.sh all --cri containerd
rm -rf /tmp/update-kube-cert

