#!/usr/bin/env bash

##### Addtional configuration for All-in-one >> replace to extra-k8s-pkgs
EXTRA_PKGS_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/extra-pkgs/v1.30"

# uninstall nfs-provisioner v4.0.2
kubectl delete -f $EXTRA_PKGS_ADDR/nfs-provisioner-v4.0.2.yaml

echo "NFS-Provisioner uninstalled successfully"
