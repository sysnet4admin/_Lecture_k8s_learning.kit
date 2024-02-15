#!/usr/bin/env bash

helm repo add edu https://k8s-edu.github.io/helm-charts/graf
helm repo update

# helm auto-completion 
helm completion bash >/etc/bash_completion.d/helm
# reload bash shell
exec bash 
