#!/usr/bin/env zsh 

# backup current context's config or create dummy
if [[ ! -f "$HOME/.kube/config" ]]; then
  :
echo "호출안됨"
else
  cp $HOME/.kube/config /tmp/kubeconfig_$(date '+%Y%m%d_%H%M%S').bak
fi 

echo "Successfully backup kubeconfig at /tmp/kubeconfig_$(date '+%Y%m%d_%H%M%S').bak"
