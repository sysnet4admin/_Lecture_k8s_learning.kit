#!/usr/bin/env bash

# vagrant_home_k8s_config 
va_k8s_cfg="/home/vagrant/.kube/config" 

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
echo 'alias k=kubectl' >> /home/vagrant/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo "alias kd='kubectl delete -f'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> /home/vagrant/.bashrc

# create .kube_config dir
sudo -u vagrant mkdir /home/vagrant/.kube

# copy kubeconfig by sshpass
sudo -u vagrant sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$2:/root/.kube/config $va_k8s_cfg-$2
sudo -u vagrant sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$3:/root/.kube/config $va_k8s_cfg-$3
sudo -u vagrant sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$4:/root/.kube/config $va_k8s_cfg-$4

# flatten .kube_config 
export KUBECONFIG=$va_k8s_cfg-$2:$va_k8s_cfg-$3:$va_k8s_cfg-$4
kubectl config view --flatten > $va_k8s_cfg 
chown vagrant:vagrant .kube/config
