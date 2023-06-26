#!/usr/bin/env bash

N = 3 

for i in {1..N}
do 
  kubectl taint node w{$i}-k8s kwok-controller/provider=test:NoSchedule
  echo "tainted on w{$i}-k8s node"
done 
