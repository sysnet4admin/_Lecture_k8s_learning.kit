#!/usr/bin/env bash

##### Addtional configuration for All-in-one >> replace to extra-k8s-pkgs
EXTRA_PKGS_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/extra-pkgs/v1.35"

# uninstall metallb v0.15.3
kubectl delete -f $EXTRA_PKGS_ADDR/metallb-native-v0.15.3.yaml

echo "MetalLB uninstalled successfully"

