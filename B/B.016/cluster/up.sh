#!/usr/bin/env bash
# Boot the cluster, then apply MetalLB after all nodes are Ready.
# For why MetalLB is applied here instead of during CP provisioning, see metallb.sh / extra_k8s_pkgs.sh.
# Idempotent: re-running on a healthy cluster returns quickly.

set -euo pipefail
source "$(dirname "$0")/config.sh"

cd "$CLUSTER_DIR"

echo "==> vagrant up"
vagrant up

echo "==> wait for all nodes (2) Ready"
until [ "$(vagrant ssh "$CP_VM" -c \
  "sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes --no-headers 2>/dev/null | grep -cw Ready" \
  2>/dev/null | tr -dc 0-9)" = "2" ]
do
  printf '.'
  sleep 15
done
echo
echo "==> 2 nodes Ready"

echo "==> apply MetalLB (workers have joined, so the controller can be scheduled)"
vagrant ssh "$CP_VM" -c "sudo KUBECONFIG=/etc/kubernetes/admin.conf bash -s" < "$CLUSTER_DIR/metallb.sh"

echo "==> final check"
vagrant ssh "$CP_VM" -c "sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes -o wide" 2>/dev/null | tail -6
vagrant ssh "$CP_VM" -c "sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl get ipaddresspool -n metallb-system" 2>/dev/null | tail -3
