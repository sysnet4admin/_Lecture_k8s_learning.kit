#!/usr/bin/env bash
# Save a snapshot across all VMs.
# Halt the VMs first, take the snapshot, then restart.
# Snapshotting while running risks VMDK CoW delta corruption.
#
# Usage: ./snapshot.sh [name]   (default: baseline)

set -euo pipefail
source "$(dirname "$0")/config.sh"

NAME="${1:-$BASELINE_SNAPSHOT}"

cd "$CLUSTER_DIR"

echo "==> halting all VMs before snapshot (prevents VMDK corruption)"
vagrant halt

echo "==> saving snapshot '$NAME' across all VMs"
vagrant snapshot save "$NAME"
vagrant snapshot list

echo "==> restarting VMs"
vagrant up

echo "==> snapshot '$NAME' complete"
