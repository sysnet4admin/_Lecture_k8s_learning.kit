#!/bin/bash
# ============================================================
# Script: Apply taints to worker nodes to change Stage 3 winner
# ============================================================
# Purpose: Demonstrate how taints affect Stage 3 scoring
#
# Current scoring without taints:
# - w1-k8s: zone-a (100) + SSD (80) = 180 points ← WINNER
# - w2-k8s: zone-a (100) + HDD (30) = 130 points
# - w3-k8s: zone-b (0) + SSD (80) = 80 points
# - w4-k8s: zone-b (0) + HDD (30) = 30 points
#
# Examples:
# With taint on w1-k8s (NoSchedule):
# - w1-k8s: FILTERED OUT (no toleration)
# - w2-k8s: zone-a (100) + HDD (30) = 130 points ← NEW WINNER
# - w3-k8s: zone-b (0) + SSD (80) = 80 points
# - w4-k8s: zone-b (0) + HDD (30) = 30 points
#
# With taint on w1-k8s (PreferNoSchedule):
# - w1-k8s: zone-a (100) + SSD (80) - penalty = lower score
# - w2-k8s: zone-a (100) + HDD (30) = 130 points ← LIKELY NEW WINNER
# - w3-k8s: zone-b (0) + SSD (80) = 80 points
# - w4-k8s: zone-b (0) + HDD (30) = 30 points
# ============================================================

set -e

# Check if fzf is available
USE_FZF=false
if command -v fzf &> /dev/null; then
    USE_FZF=true
fi

# Step 1: Select node to taint
if [ "$USE_FZF" = true ]; then
    # Use fzf for interactive selection
    echo "============================================================"
    echo "Taint worker nodes to change Stage 3 winner"
    echo "============================================================"
    echo ""
    echo "Select a node to taint (use arrow keys, type to filter, Enter to select):"
    echo ""

    # Get worker nodes with taints information and format for fzf
    NODE=$(kubectl get nodes --selector='!node-role.kubernetes.io/control-plane' -o json | jq -r '
        .items[] |
        (.metadata.name) + "|" +
        (if .spec.taints then (.spec.taints | map(.key + "=" + (.value // "") + ":" + .effect) | join(",")) else "no-taints" end) + "|" +
        (.metadata.labels.zone // "none") + "|" +
        (.metadata.labels.disktype // "none")
    ' | awk -F'|' 'BEGIN{max=0} {l=length($2); if(l>max)max=l; a[NR]=$0} END{for(i=1;i<=NR;i++){split(a[i],f,"|"); printf "%-20s taints=[%-*s] zone=%-8s disk=%-8s\n",f[1],max,f[2],f[3],f[4]}}' \
        | fzf --height=40% --layout=reverse --border --header="Select node to taint" --prompt="Node> " \
        | awk '{print $1}')

    # If no node selected (user pressed Esc or Ctrl-C)
    if [ -z "$NODE" ]; then
        echo ""
        echo "No node selected. Exiting."
        exit 0
    fi
else
    # Fallback to manual input
    echo "============================================================"
    echo "Taint worker nodes to change Stage 3 winner"
    echo "============================================================"
    echo ""
    echo "Warning: fzf not found. Falling back to manual input."
    echo ""
    echo "To install fzf:"
    echo "  macOS: brew install fzf"
    echo "  Linux: sudo apt install fzf  (or use your package manager)"
    echo ""

    # Fallback to manual input
    echo "Available worker nodes:"
    kubectl get nodes --selector='!node-role.kubernetes.io/control-plane' -o wide 2>/dev/null || kubectl get nodes -o wide
    echo ""

    echo "Enter node name to taint (e.g., w1-k8s, w2-k8s, w3-k8s, w4-k8s, w5-k8s, w6-k8s):"
    read -p "Node name: " NODE

    if [ -z "$NODE" ]; then
        echo "Error: Node name cannot be empty"
        exit 1
    fi
fi

# Check if node exists
if ! kubectl get node "$NODE" &>/dev/null; then
    echo "Error: Node $NODE not found"
    exit 1
fi

# Step 2: Show node status and taints
clear
echo "============================================================"
echo "Taint $NODE to change Stage 3 winner"
echo "============================================================"
echo ""

echo "Current node $NODE status:"
kubectl get node "$NODE" -o wide
echo ""

echo "Current taints on $NODE:"
TAINTS=$(kubectl get node "$NODE" -o jsonpath='{.spec.taints}')
if [ -z "$TAINTS" ] || [ "$TAINTS" = "null" ]; then
    echo "  No taints"
else
    echo "$TAINTS" | jq '.'
fi
echo ""

# Step 3: Select taint operation
if [ "$USE_FZF" = true ]; then
    echo "Select taint operation:"
    echo ""

    CHOICE=$(printf "%s\n" \
        "1) NoSchedule - Hard constraint (filters out node in Stage 2)" \
        "2) PreferNoSchedule - Soft constraint (lowers node score in Stage 3)" \
        "3) Remove - Remove demo taints (key=demo) from node" \
        "4) Cancel - Exit without changes" \
        | fzf --height=10 --layout=reverse --border --header="Taint operation" --prompt="Action> ")

    if [ -z "$CHOICE" ]; then
        echo ""
        echo "Cancelled"
        exit 0
    fi

    choice=$(echo "$CHOICE" | cut -d')' -f1)
else
    # Fallback to manual input
    echo "Choose taint option:"
    echo "1) NoSchedule (hard constraint - filters out $NODE in Stage 2)"
    echo "2) PreferNoSchedule (soft constraint - lowers $NODE score in Stage 3)"
    echo "3) Remove demo taints (key=demo) from $NODE"
    echo "4) Cancel"
    echo ""

    read -p "Enter choice [1-4]: " choice
fi

case $choice in
    1)
        echo ""
        echo "Applying NoSchedule taint to $NODE..."
        kubectl taint nodes "$NODE" demo=test:NoSchedule --overwrite
        echo ""
        echo "✓ NoSchedule taint applied"
        echo ""
        echo "Effect:"
        echo "- $NODE will be FILTERED OUT in Stage 2 (hard constraint)"
        echo "- comprehensive-stage3-winner Pod cannot be scheduled to $NODE"
        echo "- Scheduler will pick the next highest scoring node from remaining candidates"
        echo ""
        echo "To test:"
        echo "  kubectl delete pod comprehensive-stage3-winner 2>/dev/null || true"
        echo "  kubectl apply -f 99.comprehensive-stage3-winner.yaml"
        echo "  kubectl get pod comprehensive-stage3-winner -o wide"
        ;;
    2)
        echo ""
        echo "Applying PreferNoSchedule taint to $NODE..."
        kubectl taint nodes "$NODE" demo=test:PreferNoSchedule --overwrite
        echo ""
        echo "✓ PreferNoSchedule taint applied"
        echo ""
        echo "Effect:"
        echo "- $NODE is still a candidate but gets score penalty in Stage 3"
        echo "- TaintToleration plugin reduces $NODE score"
        echo "- Scheduler will likely pick a different node without taint penalty"
        echo ""
        echo "To test:"
        echo "  kubectl delete pod comprehensive-stage3-winner 2>/dev/null || true"
        echo "  kubectl apply -f 99.comprehensive-stage3-winner.yaml"
        echo "  kubectl get pod comprehensive-stage3-winner -o wide"
        ;;
    3)
        echo ""
        echo "Removing demo taints from $NODE..."
        kubectl taint nodes "$NODE" demo- 2>/dev/null || echo "No 'demo' taint to remove"
        echo ""
        echo "✓ Demo taints removed"
        echo ""
        echo "Effect:"
        echo "- $NODE back to full scoring without taint penalty"
        echo "- Original scoring behavior restored"
        echo ""
        echo "To test:"
        echo "  kubectl delete pod comprehensive-stage3-winner 2>/dev/null || true"
        echo "  kubectl apply -f 99.comprehensive-stage3-winner.yaml"
        echo "  kubectl get pod comprehensive-stage3-winner -o wide"
        ;;
    4)
        echo "Cancelled"
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Current taints on $NODE after change:"
kubectl get node "$NODE" -o jsonpath='{.spec.taints}' | jq '.' 2>/dev/null || echo "No taints"
echo ""

echo "============================================================"
echo "Taint operation completed"
echo "============================================================"
