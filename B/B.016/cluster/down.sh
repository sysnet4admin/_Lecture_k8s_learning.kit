#!/usr/bin/env bash
# Destroy all VMs. Use when reprovisioning from scratch.

set -euo pipefail
source "$(dirname "$0")/config.sh"

cd "$CLUSTER_DIR"

read -rp "Destroy all VMs in $CLUSTER_DIR? [y/N] " ans
case "$ans" in
  y|Y|yes|YES) vagrant destroy -f ;;
  *) echo "aborted"; exit 1 ;;
esac
