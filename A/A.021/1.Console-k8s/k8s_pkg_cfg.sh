#!/usr/bin/env bash

# install util packages 
apt-get install sshpass

# add kubernetes repo
apt-get update && apt-get install apt-transport-https curl
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

# update repo info 
apt-get update 

# install kubectl
apt-get install kubectl=$1 

# kubectl completion on bash-completion dir due to completion already installed 
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl' >> ~/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo "alias kd='kubectl delete -f'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# helm installed 
DESIRED_VERSION=v3.8.2
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
