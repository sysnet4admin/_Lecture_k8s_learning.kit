#!/usr/bin/env zsh

# backup current context's config or create dummy
if [[ ! -f "$HOME/.kube/config" ]]; then
  :
echo "Not exist $HOME/.kube/conifg"
else
  cp $HOME/.kube/config /tmp/kubeconfig_$(date '+%Y%m%d_%H%M%S').bak
  echo "Successfully backup kubeconfig at /tmp/kubeconfig_$(date '+%Y%m%d_%H%M%S').bak"
fi


# sshpass check and installation
if command -v sshpass >/dev/null 2>&1; then
    :
else
    brew install sshpass
fi

# get kubeconfig from 192.168.1.10 (API Server) to current dir
sshpass -p vagrant scp -o StrictHostKeyChecking=no root@192.168.1.10:/root/.kube/config kubeconfig

mv kubeconfig $HOME/.kube/config 
echo "Successfully set kubeconfig"
