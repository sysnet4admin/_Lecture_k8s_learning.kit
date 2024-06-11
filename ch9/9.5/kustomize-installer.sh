#!/usr/bin/env bash


curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/release-kustomize-v5.4.2/hack/install_kustomize.sh"  | bash \
        > /dev/null
mv kustomize /usr/local/bin/

echo "kustomize installed successfully"
