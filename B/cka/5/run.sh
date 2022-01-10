#!/usr/bin/env bash

sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@bk8s-w2 systemctl stop kubelet 
kubectl create deploy mal-app --image=nginx 
kubectl scale deploy mal-app --replicas=4
