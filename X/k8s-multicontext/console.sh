#!/usr/bin/env bash

# Avoid 'dpkg-reconfigure: unable to re-open stdin: No file or directory'
export DEBIAN_FRONTEND=noninteractive

# root_home_k8s_config 
va_k8s_cfg="/root/.kube/config" 

# install util packages 
apt-get install sshpass

# add kubernetes repo
apt-get update && apt-get install apt-transport-https curl
# add kubernetes repo ONLY for 22.04
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] \
  https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

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

# create .kube_config dir
mkdir /root/.kube

# copy hosts file by sshpass
sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$2:/etc/hosts /tmp/$2-hosts
sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$3:/etc/hosts /tmp/$3-hosts
sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$4:/etc/hosts /tmp/$4-hosts
cat /tmp/$2-hosts >> /etc/hosts; cat /tmp/$3-hosts >> /etc/hosts; cat /tmp/$4-hosts >> /etc/hosts

# copy kubeconfig by sshpass
sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$2:/root/.kube/config $va_k8s_cfg-$2
sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$3:/root/.kube/config $va_k8s_cfg-$3
sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.$4:/root/.kube/config $va_k8s_cfg-$4

# flatten .kube_config 
export KUBECONFIG=$va_k8s_cfg-$2:$va_k8s_cfg-$3:$va_k8s_cfg-$4
kubectl config view --flatten > $va_k8s_cfg 

# git clone k8s-code
git clone https://github.com/sysnet4admin/_Lecture_k8s_learning.kit.git
mv /home/vagrant/_Lecture_k8s_learning.kit $HOME
find $HOME/_Lecture_k8s_learning.kit -regex ".*\.\(sh\)" -exec chmod 700 {} \;

# make rerepo-k8s-learning.kit and put permission
cat <<EOF > /usr/local/bin/rerepo-k8s-learning.kit
#!/usr/bin/env bash
rm -rf $HOME/_Lecture_k8s_learning.kit
git clone https://github.com/sysnet4admin/_Lecture_k8s_learning.kit.git $HOME/_Lecture_k8s_learning.kit
find $HOME/_Lecture_k8s_learning.kit -regex ".*\.\(sh\)" -exec chmod 700 {} \;
EOF
chmod 700 /usr/local/bin/rerepo-k8s-learning.kit
