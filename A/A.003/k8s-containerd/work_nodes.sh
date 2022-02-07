#!/usr/bin/env bash

# config for work_nodes only (w/ containerd)
kubeadm join --token 123456.1234567890123456 \
             --discovery-token-unsafe-skip-ca-verification 192.168.1.10:6443 \
             --cri-socket=unix:///run/containerd/containerd.sock
