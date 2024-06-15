#!/usr/bin/env bash

kubectl apply -f ~/_Lecture_k8s_learning.kit/ch5/5.6/nfs-subdir-external-provisioner
kubectl apply -f ~/_Lecture_k8s_learning.kit/ch5/5.6/storageclass.yaml

echo "NFS-Provisioner uninstalled successfully"
