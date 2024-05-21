#!/usr/bin/env bash

RAW_GIT="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/extra-pkgs/v1.30/"

kubectl delete -f "$RAW_GIT/metallb-iprange.yaml"
kubectl delete -f "$RAW_GIT/metallb-l2mode.yaml"
kubectl delete -f "$RAW_GIT/metallb-native-v0.14.4.yaml"

echo "MetalLB uninstalled successfully"


