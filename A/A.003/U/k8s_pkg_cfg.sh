#!/usr/bin/env bash

# update package list 
apt-get update 

# install NFS 
if [ $4 = 'M' ]; then
  apt-get install nfs-server nfs-common -y 
elif [ $4 = 'W' ]; then
  apt-get install nfs-common -y 
fi

# install kubernetes
# both kubelet and kubectl will install by dependency
# but aim to latest version. so fixed version by manually
apt-get install -y kubelet=$1 kubectl=$1 kubeadm=$1 containerd.io=$3

# containerd configure to default and change cgroups to systemd 
containerd config default > /etc/containerd/config.toml
#sed -i 's/systemd_cgroup = false/systemd_cgroup = true/g' /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# remove config.toml by docker ; read containerd config again 
#rm /etc/containerd/config.toml ; systemctl restart containerd 

# Fixed container runtime to containerd
cat <<EOF > /etc/default/kubelet
KUBELET_KUBEADM_ARGS=--container-runtime=remote \
                     --container-runtime-endpoint=/run/containerd/containerd.sock \
                     --cgroup-driver=systemd
EOF

# Fixed Internal-IP  
#if   [ $4 = 'M' ]; then
#  echo -e "KUBELET_EXTRA_ARGS=--node-ip=192.168.1.10" >> /etc/default/kubelet 
#elif [ $4 = 'W' ]; then
#  for (( i=1; i<=$1; i++  ))
#  do 
#    echo -e "KUBELET_EXTRA_ARGS=--node-ip=192.168.1.10$i" >> /etc/default/kubelet 
#  done
#fi

# Avoid WARN&ERRO(default endpoints) when crictl run  
cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF

# Ready to install for k8s 
systemctl restart containerd ; systemctl enable containerd
systemctl enable --now kubelet


# install & enable docker 
apt-get install -y docker-ce=$2 docker-ce-cli=$2 
systemctl enable --now docker

