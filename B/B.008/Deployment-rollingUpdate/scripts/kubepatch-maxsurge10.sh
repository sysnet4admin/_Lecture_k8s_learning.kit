#!/usr/bin/env bash

kubectl patch deployment deploy-rollingupdate-maxsurge10 \
              -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-max10","image":"quay.io/nginx/nginx-unprivileged:'$1'"}]}}}}'

