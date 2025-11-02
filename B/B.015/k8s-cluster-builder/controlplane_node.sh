#!/usr/bin/env bash

# init kubernetes 
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
             --skip-phases=addon/kube-proxy \
             --pod-network-cidr=172.16.0.0/16 \
             --apiserver-advertise-address=192.168.1.10 

# config for control-plane node only 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# CNI raw address & config for kubernetes's network 
CNI_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/CNI"
kubectl apply -f $CNI_ADDR/cilium-v1.17.4-w-hubble.yaml
 
# kubectl completion on bash-completion dir
kubectl completion bash > /etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl'               >> ~/.bashrc
echo "alias ka='kubectl apply -f'"   >> ~/.bashrc
echo "alias kd='kubectl delete -f'"   >> ~/.bashrc
echo "alias kgpw='kubectl get pods -o wide'"   >> ~/.bashrc
echo "alias kg-po-ip-stat-no='kubectl get pods -o=custom-columns=\
NAME:.metadata.name,IP:.status.podIP,STATUS:.status.phase,NODE:.spec.nodeName'" \
                                     >> ~/.bashrc 
echo "alias kg-nodes-labels='kubectl get nodes -L zone,disktype'"   >> ~/.bashrc
echo "alias kg-nodes-taints='kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints'"   >> ~/.bashrc

echo 'complete -F __start_kubectl k' >> ~/.bashrc

# git clone talks source 
git clone https://github.com/sysnet4admin/talks
mv /home/vagrant/talks $HOME
find $HOME/talks -regex ".*\.\(sh\)" -exec chmod 700 {} \;

# make rerepo-talks and input proper permission
cat <<EOF > /usr/local/bin/rerepo-talks
#!/usr/bin/env bash
rm -rf $HOME/talks
git clone https://github.com/sysnet4admin/talks $HOME/talks
find $HOME/talks -regex ".*\.\(sh\)" -exec chmod 700 {} \;
EOF
chmod 700 /usr/local/bin/rerepo-talks

