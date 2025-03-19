#!/usr/bin/env bash

kubectl create token headlamp-admin -n headlamp -o jsonpath='{.status.token}' | sed 'G'
