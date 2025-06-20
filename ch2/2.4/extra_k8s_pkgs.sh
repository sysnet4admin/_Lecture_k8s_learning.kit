#!/usr/bin/env bash

##### Addtional configuration for All-in-one >> replace to extra-k8s-pkgs
EXTRA_PKGS_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/extra-pkgs/v1.30"

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

