#!/usr/bin/env bash

kubectl create deployment nginx-1.26.0 --image=quay.io/nginx/nginx-unprivileged:1.26.0 --replicas 6
kubectl create deployment nginx-1.26.1 --image=quay.io/nginx/nginx-unprivileged:1.26.1 --replicas 6
kubectl create deployment nginx-1.26.2 --image=quay.io/nginx/nginx-unprivileged:1.26.2 --replicas 6
kubectl create deployment nginx-1.26.3 --image=quay.io/nginx/nginx-unprivileged:1.26.3 --replicas 6
sleep 120

kubectl delete deployment nginx-1.26.0
kubectl delete deployment nginx-1.26.1
kubectl delete deployment nginx-1.26.2
kubectl delete deployment nginx-1.26.3
