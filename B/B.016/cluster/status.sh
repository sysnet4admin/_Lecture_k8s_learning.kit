#!/usr/bin/env bash
# Quick status check: VMs, snapshots, nodes, non-running pods, gateway LB IPs.

set -euo pipefail
source "$(dirname "$0")/config.sh"

cd "$CLUSTER_DIR"

echo "=== vagrant status ==="
vagrant status | tail -8

echo
echo "=== snapshots ==="
vagrant snapshot list 2>/dev/null | tail -12

echo
echo "=== kubectl context ==="
CUR_CTX=$(kubectl config current-context 2>/dev/null || echo "<none>")
echo "current: $CUR_CTX  (expected: $KUBE_CONTEXT)"

echo
echo "=== nodes ==="
kubectl --context "$KUBE_CONTEXT" get nodes 2>/dev/null || echo "(context not reachable)"

echo
echo "=== non-Running / non-Completed pods ==="
kubectl --context "$KUBE_CONTEXT" get pods -A --no-headers 2>/dev/null \
  | awk '$4 != "Running" && $4 != "Completed" {print}' \
  | head -20

echo
echo "=== LoadBalancer services (gateway IPs) ==="
kubectl --context "$KUBE_CONTEXT" get svc -A --no-headers 2>/dev/null \
  | awk '$3 == "LoadBalancer" {print}' \
  | head -20
