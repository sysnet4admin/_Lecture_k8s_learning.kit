#!/usr/bin/env bash

kubectl patch deployment deploy-default-rollingupdate-maxsurge25 \
              -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-max25","image":"quay.io/nginx/nginx-unprivileged:'$1'"}]}}}}'

