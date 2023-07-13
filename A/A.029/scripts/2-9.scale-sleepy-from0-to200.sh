#!/usr/bin/env bash

kubectl scale deploy deploy-sleepy --replicas=0

  echo -n "Waiting for deploy-sleepy's pod to zero... "
  while true; do 
    if [[ "$(kubectl get po -l app=deploy-sleepy 2>&1)" = *"No resources"* ]]; then
      echo -e "\ndeploy-sleepy have no pod"
      kubectl scale deploy deploy-sleepy --replicas=200
    else
      # print dot for waiting status 
      echo -n ".";sleep 1
    fi 
  done 

