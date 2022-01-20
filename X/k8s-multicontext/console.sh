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
