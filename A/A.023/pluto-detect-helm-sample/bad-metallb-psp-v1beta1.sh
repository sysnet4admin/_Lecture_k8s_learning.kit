#!/usr/bin/env bash

# install old metallb by helm to dev1 namespace
helm repo add edu https://iac-source.github.io/helm-charts
helm repo update

helm install metallb edu/metallb --namespace=metallb-system 

