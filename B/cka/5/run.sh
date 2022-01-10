#!/usr/bin/env bash

ssh root@bk8s-w2 systemctl stop kubelet 
kubectl create deploy mal-app --image=nginx 
kubectl scale deploy mal-app --replicas=4
