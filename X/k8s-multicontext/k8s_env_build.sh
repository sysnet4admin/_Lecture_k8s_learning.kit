#!/usr/bin/env bash

# Avoid 'dpkg-reconfigure: unable to re-open stdin: No file or directory'
export DEBIAN_FRONTEND=noninteractive

# swapoff -a to disable swapping
swapoff -a
# sed to comment the swap partition in /etc/fstab (Rmv blank)
sed -i.bak -r 's/(.+swap.+)/#\1/' /etc/fstab

# ignored gpg key due to compatibility
# echo 'APT::Get::AllowUnauthenticated “true”;' > /etc/apt/apt.conf.d/99ignoredgpg

apt-get update && apt-get install apt-transport-https ca-certificates curl
# add kubernetes repo ONLY for 22.04
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] \
  https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# add docker-ce repo
apt-get install -y \
        gnupg \
        lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# enable br_filter for iptables 
modprobe br_netfilter

# local small dns & vagrant cannot parse and delivery shell code.
echo "127.0.0.1 localhost" > /etc/hosts # localhost name will use by calico-node
echo "192.168.1.10 m-k8s" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.1.10$i w$i-k8s" >> /etc/hosts; done

# config DNS  
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF
