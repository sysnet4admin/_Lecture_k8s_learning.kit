#!/usr/bin/env bash

kubectl create deploy deploy-sleepy --image=sysnet4admin/sleepy --replicas=100
