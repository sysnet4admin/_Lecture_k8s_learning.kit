#!/usr/bin/env bash

# Fixed Internal-IP  
cat <<EOF > /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=192.168.1.$2
EOF

# config for work_nodes only 
kubeadm join --token 123456.1234567890123456 \
             --discovery-token-unsafe-skip-ca-verification 192.168.1.$1:6443

