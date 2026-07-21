#!/usr/bin/env bash
# Single source of truth for test-cluster paths and names.
# Other scripts in this folder source this file.

set -euo pipefail

# Directory containing the Vagrantfile (this file's own directory)
CLUSTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# kubectl context name bound to this cluster
KUBE_CONTEXT="kubecon-demo"

# Control-plane node (Vagrantfile define name)
CP_VM="cp-k8s-1.36.1"

# Worker node names (demo: 1)
WORKER_VMS=("w1-k8s-1.36.1")

# All VMs (CP + workers)
ALL_VMS=("$CP_VM" "${WORKER_VMS[@]}")

# Baseline snapshot name
BASELINE_SNAPSHOT="baseline"

export CLUSTER_DIR KUBE_CONTEXT CP_VM BASELINE_SNAPSHOT
