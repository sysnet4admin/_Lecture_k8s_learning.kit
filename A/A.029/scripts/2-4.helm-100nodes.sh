#!/usr/bin/env bash

helm install kwok-nodes edu/kwok \
--set kwok.node.count=100
