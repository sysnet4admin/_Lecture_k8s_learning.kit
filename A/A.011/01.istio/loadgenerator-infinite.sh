#!/usr/bin/env bash

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# infinite loop per 10 second 
echo "Press CTRL+C to stop..." 
for (( ; ; )) 
do 
  curl -s -o /dev/null "http://$INGRESS_HOST/productpage"
  sleep 10
done
