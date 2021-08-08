#!/usr/bin/env bash

kubectl label node w1-k8s topology.kubernetes.io/region=ap-northeast-2 topology.kubernetes.io/zone=ap-northeast-2a
kubectl label node w2-k8s topology.kubernetes.io/region=ap-northeast-2 topology.kubernetes.io/zone=ap-northeast-2a
kubectl label node w3-k8s topology.kubernetes.io/region=ap-northeast-2 topology.kubernetes.io/zone=ap-northeast-2b
kubectl label node w4-k8s topology.kubernetes.io/region=ap-northeast-2 topology.kubernetes.io/zone=ap-northeast-2b
