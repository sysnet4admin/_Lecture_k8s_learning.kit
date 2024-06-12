#!/usr/bin/env bash
# Main Source - https://github.com/metallb/metallb

helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system \
     --set speaker.frr.enabled=false \
     --set controller.image.tag=v0.14.5 \
     --set speaker.image.tag=v0.14.5

echo "\nWait 30 seconds for helm CRDs deployed completely" ; sleep 30
kubectl apply -f ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb-crd/

