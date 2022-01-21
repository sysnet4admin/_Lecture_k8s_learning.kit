#!/usr/bin/env bash

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for i in $(seq 1 100); do curl -s -o /dev/null "http://$INGRESS_HOST/productpage"; done
