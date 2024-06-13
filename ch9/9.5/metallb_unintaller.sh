#!/usr/bin/env bash

##### Addtional configuration for All-in-one >> replace to extra-k8s-pkgs
EXTRA_PKGS_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/extra-pkgs/v1.30"

# uninstall metallb v0.14.4
kubectl delete -f $EXTRA_PKGS_ADDR/metallb-native-v0.14.4.yaml

echo "MetalLB uninstalled successfully"

