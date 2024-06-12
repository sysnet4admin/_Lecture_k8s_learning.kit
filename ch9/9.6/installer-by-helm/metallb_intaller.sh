#!/usr/bin/env bash
# Main Source - https://github.com/metallb/metallb
# path already provided by ch2 from vagrant up

helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system \
     --set controller.image.tag=v0.10.2 \
     --set speaker.image.tag=v0.10.2 \
     -f ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/l2-config-by-helm.yaml


