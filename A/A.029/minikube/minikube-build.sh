#!/usr/bin/env bash

# kubernetes repo
gg_pkg="http://mirrors.aliyun.com/kubernetes/yum" # Due to shorten addr for key
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=${gg_pkg}/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=${gg_pkg}/doc/yum-key.gpg ${gg_pkg}/doc/rpm-package-key.gpg
EOF

# Docker!!! #
# add docker-ce repo
yum install yum-utils -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# install docker
yum install docker-ce-$2 docker-ce-cli-$2 containerd.io-$3 -y

# Ready to install for k8s
systemctl enable --now docker


# install kubectl only 
yum install kubectl-$1 -y 

# install bash-completion for kubectl 
yum install bash-completion -y 

# kubectl completion on bash-completion dir
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# install minikube binaries
curl -LO https://storage.googleapis.com/minikube/releases/v1.25.2/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# install packages for minikube 
yum -y install conntrack # network 

# startup minikube
## default 
# /usr/local/bin/minikube start --driver=none
## deploy m1 + w2 
/usr/local/bin/minikube start --force --driver=docker --nodes 3
