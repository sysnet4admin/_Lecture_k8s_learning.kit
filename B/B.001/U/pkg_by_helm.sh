#!/usr/bin/env bash

# install addtional packages
helm repo add edu https://k8s-edu.github.io/helm-charts
helm repo update
helm completion bash >/etc/bash_completion.d/helm
exec bash
#sh $HOME/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb-intaller-by-helm.sh
#sh $HOME/_Lecture_k8s_learning.kit/ch5/5.6/nfs-exporter.sh dynamic-vol
#sh $HOME/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/nfs-provisioner-installer-by-helm.sh
