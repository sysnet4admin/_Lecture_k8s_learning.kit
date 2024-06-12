#!/usr/bin/env bash
# Main Source - https://github.com/metallb/metallb
# path already provided by ch2 from vagrant up

helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system \
     --set controller.image.tag=v0.14.5 \
     --set speaker.image.tag=v0.14.5 \
     -f ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb-crd/metallb-l2mode.yaml
     -f ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb-crd/metallb-iprange.yaml

