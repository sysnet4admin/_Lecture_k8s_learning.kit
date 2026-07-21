#!/usr/bin/env bash
# Restore all VMs to the baseline snapshot (fast scenario reset).

set -euo pipefail
source "$(dirname "$0")/config.sh"

cd "$CLUSTER_DIR"

echo "==> restoring snapshot '$BASELINE_SNAPSHOT' on all VMs"
vagrant snapshot restore "$BASELINE_SNAPSHOT"

echo "==> restored; verifying cluster health"
vagrant ssh "$CP_VM" -c "sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes --no-headers" 2>/dev/null | tail -10
