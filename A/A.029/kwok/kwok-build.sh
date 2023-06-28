#!/usr/bin/env bash

# Avoid 'dpkg-reconfigure: unable to re-open stdin: No file or directory' message 
export DEBIAN_FRONTEND=noninteractive

# prerequirement # 
apt-get update 
## installation 
apt-get install -y \
        ca-certificates \
        gnupg \
        lsb-release \
        jq \
        git \
        golang 

# git clone k8s-code
git clone https://github.com/sysnet4admin/_Lecture_k8s_learning.kit.git
mv /home/vagrant/_Lecture_k8s_learning.kit $HOME
find $HOME/_Lecture_k8s_learning.kit -regex ".*\.\(sh\)" -exec chmod 700 {} \;

# KWOK!!! Variables preparation #
## KWOK repository
KWOK_REPO=kubernetes-sigs/kwok
## Get latest
# KWOK_LATEST_RELEASE=$(curl "https://api.github.com/repos/${KWOK_REPO}/releases/latest" | jq -r '.tag_name')
### Fixed version 
KWOK_LATEST_RELEASE="v0.3.0"

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
kubectl apply -f https://raw.githubusercontent.com/sysnet4admin/_Lecture_k8s_learning.kit/main/A/A.029/9-bulk-nodes-w-taints.yaml

# install helm 
export DESIRED_VERSION="v3.12.0"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh 

# helm completion on bash-completion dir & alias+ 
helm completion bash > /etc/bash_completion.d/helm
echo 'alias h=helm' >> ~/.bashrc
echo 'complete -F __start_helm h' >> ~/.bashrc 

# add & update repo
helm repo add edu https://k8s-edu.github.io/helm-charts/k8s
helm repo update

