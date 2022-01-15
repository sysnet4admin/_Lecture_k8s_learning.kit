#!/usr/bin/env bash

# root_home_k8s_config 
va_k8s_cfg="/root/.kube/config" 

# install util packages 
apt install sshpass

# add kubernetes repo
apt update && apt install apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# update repo info 
apt update 

# install kubectl
apt install kubectl=$1 

# kubectl completion on bash-completion dir due to completion already installed 
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl' >> ~/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo "alias kd='kubectl delete -f'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# create .kube_config dir
mkdir /root/.kube

