#!/usr/bin/env bash

# helm env add (move to parent vagrantfile)
# PATH=$PATH:/usr/local/bin

# k8s-extra-pkgs addr 
EXTRA_PKGS="https://raw.githubusercontent.com/sysnet4admin/IaC/master/k8s/extra-pkgs/v1.27.2"

# helm 3.9.1 installer 
curl -s $EXTRA_PKGS/get-helm-3.12.0.sh | bash 
# repo edu add 
helm repo add edu https://k8s-edu.github.io/helm-charts
helm repo update
# helm auto-completion
helm completion bash >/etc/bash_completion.d/helm
# helm completion on bash-completion dir & alias+ 
helm completion bash > /etc/bash_completion.d/helm
echo 'alias h=helm' >> ~/.bashrc
echo 'complete -F __start_helm h' >> ~/.bashrc 

# metallb v0.13.7
kubectl apply -f $EXTRA_PKGS/metallb-native-v0.13.10.yaml

# split metallb CRD due to it cannot apply at once. 
# it looks like Operator limitation
# QA: 
# - 240sec cannot deploy on intel MAC. So change Seconds 
# - 300sec can deploy but safety range is from 540 - 600 

# config metallb layer2 mode 
(sleep 540 && kubectl apply -f $EXTRA_PKGS/metallb-l2mode.yaml)&
# config metallb ip range and it cannot deploy now due to CRD cannot create yet 
(sleep 600 && kubectl apply -f $EXTRA_PKGS/metallb-iprange.yaml)&

# metrics server v0.6.3 - insecure mode 
kubectl apply -f $EXTRA_PKGS/metrics-server-notls-0.6.3.yaml

# NFS dir configuration with vairable 
curl -L $EXTRA_PKGS/nfs-exporter.sh -o /tmp/nfs-exporter.sh
chmod 755 /tmp/nfs-exporter.sh
/tmp/nfs-exporter.sh dynamic-vol
rm /tmp/nfs-exporter.sh  

# nfs-provsioner installer 
kubectl apply -f  $EXTRA_PKGS/nfs-provisioner-4.0.2.yaml

# storageclass installer & set default storageclass
kubectl apply -f $EXTRA_PKGS/storageclass.yaml 

# setup default storage class due to no mention later on
kubectl annotate storageclass managed-nfs-storage storageclass.kubernetes.io/is-default-class=true

