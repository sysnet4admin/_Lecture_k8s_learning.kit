#!/usr/bin/env bash

# config for worker nodes only
kubeadm join --token 123456.1234567890123456 \
             --discovery-token-unsafe-skip-ca-verification $1:6443
