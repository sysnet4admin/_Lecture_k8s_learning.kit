#!/usr/bin/env bash
# Main Source - https://github.com/metallb/metallb
# path already provided by ch2 from vagrant up

helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system \
     -f ~/_Lecture_k8s_learning.kit/ch9/9.6/l2-config-by-helm.yaml


