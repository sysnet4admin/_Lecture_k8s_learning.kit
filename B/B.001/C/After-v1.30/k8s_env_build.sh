#!/usr/bin/env bash

# vim configuration 
echo 'alias vi=vim' >> /etc/profile

# swapoff -a to disable swapping
swapoff -a
# sed to comment the swap partition in /etc/fstab
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

# kubernetes repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v$2/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v$2/rpm/repodata/repomd.xml.key
EOF

# add docker-ce repo
yum install yum-utils -y 
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Setup required sysctl params, these persist across reboots
# packets traversing the bridge are processed by iptables for filtering
echo 1 > /proc/sys/net/ipv4/ip_forward
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

# Load br_netfilter(/etc/modules-load.d/containerd.conf)  
modprobe br_netfilter

# local small dns & vagrant cannot parse and delivery shell code.
echo "192.168.1.10 cp-k8s" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.1.10$i w$i-k8s" >> /etc/hosts; done

# config DNS  
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF

