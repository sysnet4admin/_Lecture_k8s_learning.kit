#!/usr/bin/env bash

kubectl delete -f ~/_Lecture_k8s_learning.kit/ch4/4.4/metallb-iprange.yaml
kubectl delete -f ~/_Lecture_k8s_learning.kit/ch4/4.4/metallb-l2mode.yaml
kubectl delete -f ~/_Lecture_k8s_learning.kit/ch4/4.4/metallb-native-v0.14.4.yaml

echo "MetalLB uninstalled successfully"


