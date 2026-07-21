#!/usr/bin/env bash
# Runs on the CP node (with KUBECONFIG set). Called by up.sh after workers have joined and
# a schedulable node exists. On a tainted single CP node the MetalLB controller stays Pending,
# so applying it during CP provisioning fails (a past bug). Hence it is split out to after nodes
# are Ready.

set -euo pipefail

echo "==> apply MetalLB v0.15.3"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml

echo "==> wait for controller Ready"
kubectl -n metallb-system rollout status deploy/controller --timeout=300s

echo "==> apply gateway-pool(.11-17) + L2Advertisement"
# The webhook ClusterIP takes a few seconds to be programmed (kube-proxy), so applying
# right after rollout can hit 'no route to host'. Absorb it with retries.
APPLY_POOL() {
  kubectl apply -f - <<'EOF'
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: gateway-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.11-192.168.1.17
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: gateway-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - gateway-pool
EOF
}
applied=false
for i in $(seq 1 20); do
  if APPLY_POOL; then echo "==> MetalLB applied"; applied=true; break; fi
  echo "   retry $i (waiting for webhook programming)..."; sleep 10
done
# Fail LOUDLY if the pool never applied. Without this the loop just ended and the script exited 0,
# leaving a cluster with MetalLB core but NO IPAddressPool → every LB Service stays <pending> while
# up.sh reports success (the exact trap that made ingress-nginx never get its demo IP).
if [ "$applied" != true ]; then
  echo "✗ MetalLB IPAddressPool/L2Advertisement never applied (webhook not programmed after 20 retries)." >&2
  exit 1
fi
