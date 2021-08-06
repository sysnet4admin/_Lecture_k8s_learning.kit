#!/usr/bin/env bash

kubectl patch node w1-k8s -p '{"spec":{"taints":[]}}'
kubectl patch node w2-k8s -p '{"spec":{"taints":[]}}'
kubectl patch node w3-k8s -p '{"spec":{"taints":[]}}'

# Check status of taints
CODE=$(kubectl get node -o yaml |  grep -i taints | wc -l)

echo "successfully init taints in the k8s cluster"
echo "Result code is $CODE"
echo "if Result is not 1, please reload all of worker nodes"
