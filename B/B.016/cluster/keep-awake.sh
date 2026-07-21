#!/usr/bin/env bash
# Prevent host system sleep only while the gateway-poc VMs are running.
# (Host sleep can put a VirtualBox VM into 'paused due to host power management', which breaks
#  halt/measurement. Actually happened on a halt on 2026-06-05.)
# Does not block display sleep (-is = idle + AC system sleep only). Exits automatically once all
# VMs are halted.
#
# Use: run once after vagrant up →  ./keep-awake.sh
# Stop: to stop manually,  pkill -f GWPOC_CAFFEINATE  (usually unnecessary; exits on halt)
set -uo pipefail

pkill -f "GWPOC_CAFFEINATE" 2>/dev/null || true
sleep 1
VBOXMANAGE="$(command -v VBoxManage)"
[ -z "$VBOXMANAGE" ] && { echo "VBoxManage not found"; exit 1; }

nohup bash -c "
# GWPOC_CAFFEINATE manager
while \"$VBOXMANAGE\" list runningvms 2>/dev/null | grep -q '1.36.1-gateway-poc'; do
  caffeinate -is -t 270
done
" > /tmp/gwpoc-caffeinate.log 2>&1 &
echo "caffeinate manager started PID=$! (exits automatically once all gateway-poc VMs are halted)"
