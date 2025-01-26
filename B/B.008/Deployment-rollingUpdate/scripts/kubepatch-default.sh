#!/usr/bin/env bash

kubectl patch deployment deploy-default-rollingUpdate-maxsurge25 \
              -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-max25","image":"$1"}]}}}}'

