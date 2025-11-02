# Stage 3: Scoring-Based Winner Selection

This directory demonstrates how **Stage 3 scoring determines the winner** when multiple nodes pass Stage 2 filtering.

## Overview

Stage 3 is where the Kubernetes scheduler evaluates **soft constraints** (preferences) and assigns scores to candidate nodes. The node with the **highest score wins**.

This demo shows how scoring drives placement decisions through three scenarios:
- **Scenario 1**: All 4 nodes available → Highest score (180) wins
- **Scenario 2**: Top node eliminated → Next highest score (130) wins
- **Scenario 3**: Top 2 nodes eliminated → Third highest score (80) wins

We use `taint-node.sh` as a tool to eliminate nodes and observe how scoring selects the next best candidate.

## Understanding Stage 3 Scoring

### How Scoring Works

The scheduler assigns points to each node based on how well it matches the preferences:

```yaml
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 100  # Strong preference
  preference:
    matchExpressions:
    - key: zone
      operator: In
      values: [zone-a]

- weight: 80   # Medium preference
  preference:
    matchExpressions:
    - key: disktype
      operator: In
      values: [ssd]
```

Each preference has a **weight** (importance level). Nodes matching the preference get those points. The node with the **highest total score wins**.

## Three Test Scenarios

### Scenario 1: All Nodes Available (Scoring Decides)

**Objective**: See how Stage 3 scoring picks the best node when all candidates are available

```bash
# Deploy the comprehensive test
kubectl apply -f 99.score-picks-winner.yaml

# Check placement
kubectl get pod score-picks-winner -o wide
# Expected: w1-k8s (highest score: 180 points)

# Verify scheduling decision
kubectl describe pod score-picks-winner | grep -A5 Events
```

**Scoring without taints:**

| Node | Zone | Disk | Zone Score (weight 100) | Disk Score (weight 80) | Total | Result |
|------|------|------|------------------------|------------------------|-------|--------|
| w1-k8s | zone-a | ssd | 100 | 80 | **180** | ✅ WINNER |
| w2-k8s | zone-a | hdd | 100 | 30 | 130 | |
| w3-k8s | zone-b | ssd | 0 | 80 | 80 | |
| w4-k8s | zone-b | hdd | 0 | 30 | 30 | |

**Key Point**:
- **Scoring drives the decision**: w1-k8s has the highest score (180)
- Matches both preferences: zone-a (100 points) + ssd (80 points)
- Stage 3 scoring selected w1-k8s as the optimal placement

---

### Scenario 2: Top Scorer Eliminated (Next Best Score Wins)

**Objective**: Show that when the highest-scoring node is unavailable, Stage 3 scoring picks the next best

```bash
# Apply taint to w1-k8s using interactive script
./taint-node.sh

# Interactive steps:
# 1. Select w1-k8s (using fzf)
# 2. Choose "1) NoSchedule - Hard constraint (filters out node in Stage 2)"
# 3. Observe the effect message

# Redeploy the pod
kubectl delete pod score-picks-winner
kubectl apply -f 99.score-picks-winner.yaml

# Check new placement
kubectl get pod score-picks-winner -o wide
# Expected: w2-k8s (NEW WINNER - w1 filtered out in Stage 2)

# Verify w1 is filtered out
kubectl describe pod score-picks-winner | grep -A5 Events
```

**Scoring after NoSchedule taint on w1-k8s:**

| Node | Status | Score | Result |
|------|--------|-------|--------|
| w1-k8s | FILTERED OUT (Stage 2) | N/A | ❌ Eliminated |
| w2-k8s | Candidate | 130 | ✅ NEW WINNER |
| w3-k8s | Candidate | 80 | |
| w4-k8s | Candidate | 30 | |

**Key Point**:
- **Scoring still drives the decision**: w2-k8s has the highest score among remaining nodes (130)
- w1-k8s (180 points) is unavailable → eliminated in Stage 2
- Stage 3 scoring picks the next highest: w2-k8s (130 points)
- Still matches one preference: zone-a (100 points) + hdd (30 points)

---

### Scenario 3: Top 2 Scorers Eliminated (Third Best Score Wins)

**Objective**: Show that scoring continues to drive decisions even when only lower-scoring nodes remain

```bash
# Keep w1-k8s tainted, now taint w2-k8s as well
./taint-node.sh

# Interactive steps:
# 1. Select w2-k8s (using fzf)
# 2. Choose "1) NoSchedule - Hard constraint (filters out node in Stage 2)"
# 3. Observe the effect message

# Redeploy the pod
kubectl delete pod score-picks-winner
kubectl apply -f 99.score-picks-winner.yaml

# Check new placement
kubectl get pod score-picks-winner -o wide
# Expected: w3-k8s (NEW WINNER - w1 and w2 filtered out)

# Verify w1 and w2 are filtered out
kubectl describe pod score-picks-winner | grep -A5 Events
```

**Scoring after NoSchedule taints on both w1-k8s and w2-k8s:**

| Node | Status | Score | Result |
|------|--------|-------|--------|
| w1-k8s | FILTERED OUT (Stage 2) | N/A | ❌ Eliminated |
| w2-k8s | FILTERED OUT (Stage 2) | N/A | ❌ Eliminated |
| w3-k8s | Candidate | 80 | ✅ NEW WINNER |
| w4-k8s | Candidate | 30 | |

**Key Point**:
- **Scoring always drives the decision**: w3-k8s has the highest score among remaining nodes (80)
- w1-k8s (180 points) and w2-k8s (130 points) are unavailable
- Stage 3 scoring picks the highest remaining: w3-k8s (80 points)
- Partial match is enough: ssd (80 points), zone-b doesn't match (0 points)
- Demonstrates that Stage 3 **always selects based on relative scores**, not absolute values

---

### Cleanup: Restore Original State

```bash
# Remove all taints to restore baseline
./taint-node.sh

# Remove taint from w1-k8s:
# 1. Select w1-k8s
# 2. Choose "3) Remove - Remove all demo taints from node"

./taint-node.sh

# Remove taint from w2-k8s:
# 1. Select w2-k8s
# 2. Choose "3) Remove - Remove all demo taints from node"

# Redeploy and verify w1-k8s is back as winner
kubectl delete pod score-picks-winner
kubectl apply -f 99.score-picks-winner.yaml
kubectl get pod score-picks-winner -o wide
# Expected: w1-k8s (back to original winner)
```

## Using taint-node.sh

### Features

- **Interactive node selection** with fzf (shows current taints and labels)
- **Three taint operations**:
  - `NoSchedule`: Hard constraint (filters out node in Stage 2)
  - `PreferNoSchedule`: Soft constraint (lowers node score in Stage 3)
  - `Remove`: Removes demo taints
- **Current state display**: Shows node status and taints before operation
- **Test commands**: Provides copy-paste commands to verify changes

### Usage

```bash
# Run the script
./taint-node.sh

# Interactive flow:
# 1. Select node (arrow keys to navigate, Enter to select)
# 2. Review current taints
# 3. Select operation
# 4. Script applies taint and shows test commands
# 5. Follow test commands to observe the effect
```

### Example Output

```
============================================================
Taint worker nodes to change Stage 3 winner
============================================================

Select a node to taint (use arrow keys, type to filter, Enter to select):

w1-k8s               taints=[no-taints]                  zone=zone-a   disk=ssd
w2-k8s               taints=[no-taints]                  zone=zone-a   disk=hdd
w3-k8s               taints=[no-taints]                  zone=zone-b   disk=ssd
w4-k8s               taints=[no-taints]                  zone=zone-b   disk=hdd

============================================================
Taint w1-k8s to change Stage 3 winner
============================================================

Current node w1-k8s status:
NAME     STATUS   ROLES    AGE   VERSION
w1-k8s   Ready    <none>   15d   v1.34.1

Current taints on w1-k8s:
  No taints

Select taint operation:

1) NoSchedule - Hard constraint (filters out node in Stage 2)
2) PreferNoSchedule - Soft constraint (lowers node score in Stage 3)
3) Remove - Remove all demo taints from node
4) Cancel - Exit without changes

✓ NoSchedule taint applied

Effect:
- w1-k8s will be FILTERED OUT in Stage 2 (hard constraint)
- score-picks-winner Pod cannot be scheduled to w1-k8s
- Scheduler will pick the next highest scoring node from remaining candidates

To test:
  kubectl delete pod score-picks-winner 2>/dev/null || true
  kubectl apply -f 99.score-picks-winner.yaml
  kubectl get pod score-picks-winner -o wide
```

## Key Takeaways: Stage 3 Scoring Determines Winners

### The Core Principle
**Stage 3 scoring always picks the highest-scoring available node**

### What We Demonstrated

1. **Scoring is relative, not absolute**
   - Scenario 1: 180 points wins (out of 180, 130, 80, 30)
   - Scenario 2: 130 points wins (out of 130, 80, 30)
   - Scenario 3: 80 points wins (out of 80, 30)
   - The winner is always the **highest score among available candidates**

2. **Stage 3 scoring drives all placement decisions**
   - Not about meeting thresholds
   - About **relative ranking** of available nodes
   - Preferences create scoring differences that determine winners

3. **When high-scoring nodes are unavailable, the next best wins**
   - Winner progression by score: 180 → 130 → 80
   - Each step shows scoring selecting the optimal available node

4. **Role of taint-node.sh**
   - Tool to eliminate nodes (simulating capacity, failures, maintenance)
   - Demonstrates that scoring adapts to available candidates
   - Shows Stage 3's consistent logic regardless of candidate pool

## Cleanup

```bash
# Remove demo taints from w1-k8s
./taint-node.sh
# Select w1-k8s and choose "3) Remove - Remove all demo taints from node"

# Remove demo taints from w2-k8s
./taint-node.sh
# Select w2-k8s and choose "3) Remove - Remove all demo taints from node"

# Or remove manually
kubectl taint nodes w1-k8s demo- 2>/dev/null || true
kubectl taint nodes w2-k8s demo- 2>/dev/null || true

# Delete test pod
kubectl delete pod score-picks-winner
```
