#!/usr/bin/env bash

# install old metallb by helm
helm repo add iac https://iac-source.github.io/helm-charts
helm repo update
 
helm install metallb iac/metallb \
--namespace=metallb-system \
--create-namespace 

