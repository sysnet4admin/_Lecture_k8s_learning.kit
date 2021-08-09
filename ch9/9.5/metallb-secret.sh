#!/usr/bin/env bash

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl get secret memberlist -n metallb-system
