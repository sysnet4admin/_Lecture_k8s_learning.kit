#!/usr/bin/env zsh

# sshpass check and installation
if command -v sshpass >/dev/null 2>&1; then
    :
else
    brew install sshpass
fi

# get kubeconfig from 192.168.1.10 (API Server) to current dir
sshpass -p vagrant scp -o StrictHostKeyChecking=no root@192.168.1.10:/root/.kube/config kubeconfig

# backup current context's config or create dummy
if [[ ! -f "$HOME/.kube/config" ]]; then
    touch $HOME/.kube/config
else
    cp $HOME/.kube/config /tmp/kubeconfig-backup
fi

# flatten .kube_config
export KUBECONFIG=/tmp/kubeconfig-backup:kubeconfig
kubectl config view --flatten > $HOME/.kube/config

# clear downloaded kubeconfig
rm kubeconfig

echo "Successfully flatten kubeconfig"
