#!/usr/bin/env bash

kubectl patch deployment deploy-rollingupdate-maxsurge80 \
              -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-max80","image":"quay.io/nginx/nginx-unprivileged:'$1'"}]}}}}'

