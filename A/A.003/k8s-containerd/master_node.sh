#!/usr/bin/env bash

# init kubernetes (w/ containerd)
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
--pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.1.10 \
--cri-socket=unix:///run/containerd/containerd.sock

# config for master node only 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# raw_address for gitcontent
raw_git="raw.githubusercontent.com/sysnet4admin/IaC/master/manifests" 

# config for kubernetes's network 
kubectl apply -f https://$raw_git/172.16_net_calico_v1.yaml

# config metallb for LoadBalancer service > upgrade
kubectl apply -f https://$raw_git/svc/metallb-0.10.2.yaml

# create configmap for metallb (192.168.1.11 - 49) > upgrade
kubectl apply -f https://$raw_git/svc/metallb-l2config-xd.yaml

# create secret for metallb 
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# install bash-completion for kubectl 
yum install bash-completion -y 

# kubectl completion on bash-completion dir
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl' >> ~/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

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

##### Addtional configuration for All-in-one
# install deploying tools 
sh $HOME/_Lecture_k8s_learning.kit/ch9/9.5/kustomize-installer.sh
sh $HOME/_Lecture_k8s_learning.kit/ch9/9.6/get_helm.sh >/dev/null 2>&1

# helm completion on bash-completion dir and run manually due to hem limitation. 
cat <<EOF > /tmp/helm_completion.sh
helm completion bash >/etc/bash_completion.d/helm
exec bash
EOF

# install nfs-provisioner
sh $HOME/_Lecture_k8s_learning.kit/ch5/5.6/nfs-exporter.sh dynamic-vol
kubectl apply -f $HOME/_Lecture_k8s_learning.kit/ch5/5.6/nfs-subdir-external-provisioner
kubectl apply -f $HOME/_Lecture_k8s_learning.kit/ch5/5.6/storageclass.yaml

# install metrics-server 
cd $HOME/_Lecture_k8s_learning.kit/ch9/9.7/metrics-server/ ; kubectl apply -k .

# create dev1, dev2 namespaces
kubectl create ns dev1
kubectl create ns dev2
