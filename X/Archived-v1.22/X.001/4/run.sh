#!/usr/bin/env bash

kubectl apply -f local-storage.yaml
sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@bk8s-w1 mkdir -p /data/vol/pv
