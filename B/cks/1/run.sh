#!/usr/bin/env bash

kubectl create ns sensitive
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: db
  name: db
  namespace: sensitive 
spec:
  containers:
  - image: sysnet4admin/sleepy
    name: db
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF
