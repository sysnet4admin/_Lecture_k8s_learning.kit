#!/usr/bin/env bash

##### Addtional configuration for All-in-one >> replace to extra-k8s-pkgs
EXTRA_PKGS_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/extra-pkgs/v1.30"

curl $EXTRA_PKGS_ADDR/get_helm_v3.14.0.sh | bash 
# helm completion on bash-completion dir & alias+
helm completion bash > /etc/bash_completion.d/helm
echo 'alias h=helm' >> ~/.bashrc
echo 'complete -F __start_helm h' >> ~/.bashrc

# metallb v0.14.4
kubectl apply -f $EXTRA_PKGS_ADDR/metallb-native-v0.14.4.yaml

# split metallb CRD due to it cannot apply at once. 
# it looks like Operator limitation
# QA: 
# - 240sec cannot deploy on intel MAC. So change Seconds 
# - 300sec can deploy but safety range is from 540 - 600 

# config metallb layer2 mode 
(sleep 540 && kubectl apply -f $EXTRA_PKGS_ADDR/metallb-l2mode.yaml)&
# config metallb ip range and it cannot deploy now due to CRD cannot create yet 
(sleep 600 && kubectl apply -f $EXTRA_PKGS_ADDR/metallb-iprange.yaml)&

# nginx ingress ctrl v1.10.1(loadbalancer) 
kubectl apply -f $EXTRA_PKGS_ADDR/ingress-ctrl-loadbalancer-v1.10.1.yaml 

# metrics server v0.7.1 - insecure mode 
kubectl apply -f $EXTRA_PKGS_ADDR/metrics-server-notls-v0.7.1.yaml

# NFS dir configuration
curl $EXTRA_PKGS_ADDR/nfs_exporter.sh | bash -s -- "dynamic-vol"

# nfs-provsioner v4.0.2 installer 
kubectl apply -f $EXTRA_PKGS_ADDR/nfs-provisioner-v4.0.2.yaml

# storageclass installer & set default storageclass
kubectl apply -f $EXTRA_PKGS_ADDR/storageclass.yaml 

# setup default storage class due to no mention later on
kubectl annotate storageclass managed-nfs-storage storageclass.kubernetes.io/is-default-class=true


