#!/usr/bin/env bash

# prerequirement # 
## installation 
apt-get install -y \
        ca-certificates \
        gnupg \
        lsb-release \
        jq \
        git \
        golang 

# git clone the source 
git clone https://github.com/sysnet4admin/_Lecture_k8s_starter.kit.git

# KWOK!!! Variables preparation #
## KWOK repository
KWOK_REPO=kubernetes-sigs/kwok
## Get latest
KWOK_LATEST_RELEASE=$(curl "https://api.github.com/repos/${KWOK_REPO}/releases/latest" | jq -r '.tag_name')

# Install kwokctl #
wget -O kwokctl -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwokctl-$(go env GOOS)-$(go env GOARCH)"
chmod +x kwokctl
sudo mv kwokctl /usr/local/bin/kwokctl

# Install kwok #
wget -O kwok -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwok-$(go env GOOS)-$(go env GOARCH)"
chmod +x kwok
sudo mv kwok /usr/local/bin/kwok

# Docker!!! #
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update 

# install & enable docker 
apt-get install -y docker-ce=$2 docker-ce-cli=$2 
systemctl enable --now docker

# install kubectl 
curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl
sudo chmod +x kubectl 
mv kubectl /usr/local/bin/kubectl

# kubectl completion on bash-completion dir
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl' >> ~/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo "alias kd='kubectl delete -f'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# Deploy KWOK Cluster 
kwokctl create cluster --name=demo 

# Set context for KWOK Cluster 
kubectl config use-context kwok-demo 

# Add 9 nodes for kwok 
kubectl apply -f https://raw.githubusercontent.com/sysnet4admin/_Lecture_k8s_starter.kit/main/ch8/014/add-9-bulk-nodes-w-taints.yaml

