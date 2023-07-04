#!/usr/bin/env bash

kubectl create deploy deploy-nginx --image=nginx --replicas=1000
