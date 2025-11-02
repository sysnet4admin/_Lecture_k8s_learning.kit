# Stage 2: When Filters Make Scoring Meaningless

This directory demonstrates how **Stage 2 filtering can make Stage 3 scoring irrelevant** by leaving no choice or creating scenarios where scoring preferences don't matter.

## Overview

Stage 2 is where the Kubernetes scheduler applies **hard constraints** (required filters). Nodes that don't meet these requirements are immediately eliminated. Stage 3 then scores the remaining nodes using **soft constraints** (preferences).

But what happens when Stage 2 filters are so restrictive that Stage 3 scoring becomes meaningless?

This demo shows three scenarios where Stage 2 makes Stage 3 irrelevant:
- **Scenario 97**: 0 nodes remain → Stage 3 never evaluated (Unschedulable)
- **Scenario 98**: Only 1 node remains → No choice for Stage 3
- **Scenario 99**: 2 nodes remain, but Filter excludes Score's favorite → Misalignment

## Understanding Stage 2 Filtering vs Stage 3 Scoring

### Stage 2: Hard Constraints (Filter)

All conditions **must** be satisfied. Failing any filter eliminates the node:

```yaml
spec:
  nodeSelector:
    disktype: ssd  # MUST match

  tolerations:
  - key: gpu
    operator: Equal
    value: nvidia
    effect: NoSchedule  # MUST tolerate

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:  # MUST satisfy
        nodeSelectorTerms:
        - matchExpressions:
          - key: zone
            operator: In
            values: [zone-c]
```

### Stage 3: Soft Constraints (Score)

Preferences influence placement but don't block scheduling:

```yaml
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:  # Nice to have
      - weight: 100
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values: [zone-a]  # Preferred, not required
```

## Three Test Scenarios

### Scenario 97: Zero Nodes Remaining (Unschedulable)

**File**: `97.filter-leaves-zero-nodes-unschedulable.yaml`

**Objective**: Show that when Stage 2 leaves zero nodes, Stage 3 scoring is never evaluated and the Pod stays Pending

```bash
# Deploy the test
kubectl apply -f 97.filter-leaves-zero-nodes-unschedulable.yaml

# Check status
kubectl get pod filter-leaves-zero-nodes-unschedulable -o wide
# Expected: STATUS = Pending (no node assigned)

# Verify why it failed to schedule
kubectl describe pod filter-leaves-zero-nodes-unschedulable | grep -A10 Events
# Expected: "0/6 nodes are available" message
```

#### How Stage 2 Filters to Zero Nodes

**Stage 2 Filter Chain:**

| Filter Step | Condition | Nodes Remaining |
|-------------|-----------|-----------------|
| Initial | All nodes | w1, w2, w3, w4, w5, w6 |
| Filter 1 | `nodeSelector: disktype=ssd` | w1, w3, w5 (SSD nodes) |
| Filter 2 | `requiredNodeAffinity: zone=zone-c, disktype=ssd` | w5 (only match) |
| Filter 3 | `tolerations: gpu=nvidia` (NOT PROVIDED) | **None** (w5 has gpu taint, filtered out) |

**Result**: Zero nodes remain after Stage 2

#### Stage 3 Scoring is Never Evaluated

**Stage 3 Preferences** (what the Pod wants):
- Prefer zone-a nodes (weight: 100)
- Prefer HDD nodes (weight: 50)

**Reality** (what's available):
- No nodes available

**Scoring Table:**

| Node | Status | Score | Result |
|------|--------|-------|--------|
| (all nodes) | FILTERED OUT | N/A | ❌ Pod Unschedulable |

**Key Point**:
- **Stage 3 is never evaluated** because there are no candidates
- Stage 3 preferences (zone-a, HDD) are **completely irrelevant**
- Pod stays in Pending state (Unschedulable)
- **No candidates = No scoring, No scheduling**
- This is the most extreme case of Stage 2 dominance

---

### Scenario 98: One Node Remaining (No Choice)

**File**: `98.filter-leaves-one-node-score-bypassed.yaml`

**Objective**: Show that when Stage 2 leaves only one node, Stage 3 scoring is completely bypassed

```bash
# Deploy the test
kubectl apply -f 98.filter-leaves-one-node-score-bypassed.yaml

# Check placement
kubectl get pod filter-leaves-one-node-score-bypassed -o wide
# Expected: w5-k8s (zone-c, SSD, GPU taint)

# Verify scheduling decision
kubectl describe pod filter-leaves-one-node-score-bypassed | grep -A10 Events
```

#### How Stage 2 Filters to One Node

**Stage 2 Filter Chain:**

| Filter Step | Condition | Nodes Remaining |
|-------------|-----------|-----------------|
| Initial | All nodes | w1, w2, w3, w4, w5, w6 |
| Filter 1 | `nodeSelector: disktype=ssd` | w1, w3, w5 (SSD nodes) |
| Filter 2 | `tolerations: gpu=nvidia` | w5 (only node with gpu taint) |
| Filter 3 | `requiredNodeAffinity: zone=zone-c, disktype=ssd` | **w5** (only match) |

**Result**: Only w5-k8s remains after Stage 2

#### Stage 3 Scoring is Bypassed

**Stage 3 Preferences** (what the Pod wants):
- Prefer zone-a nodes (weight: 100)
- Prefer HDD nodes (weight: 50)

**Reality** (what it gets):
- w5-k8s: zone-c + SSD (opposite of preferences!)

**Scoring Table:**

| Node | Zone Pref (100) | Disk Pref (50) | Total | Status |
|------|-----------------|----------------|-------|--------|
| w5-k8s | 0 (zone-c ≠ zone-a) | 0 (ssd ≠ hdd) | **0** | ✅ FORCED (only option) |

**Key Point**:
- **Stage 3 is not evaluated** because there's only one candidate
- Stage 3 preferences (zone-a, HDD) had **ZERO impact**
- w5-k8s gets scheduled despite scoring 0 points
- **No choice = No scoring needed**

---

### Scenario 99: Two Nodes Remaining, Both Score Zero (Meaningless Tie)

**File**: `99.filter-leaves-two-nodes-score-zero.yaml`

**Objective**: Show that when Stage 2 leaves multiple nodes but Stage 3 preferences don't match any of them, scoring becomes meaningless

```bash
# Deploy the test
kubectl apply -f 99.filter-leaves-two-nodes-score-zero.yaml

# Check placement
kubectl get pod filter-leaves-two-nodes-score-zero -o wide
# Expected: w3-k8s or w5-k8s (NOT w1-k8s!)

# Verify scheduling decision
kubectl describe pod filter-leaves-two-nodes-score-zero | grep -A10 Events
```

#### How Stage 2 Filters to Two Nodes (Excludes w1)

**Stage 2 Filter Chain:**

| Filter Step | Condition | Nodes Remaining |
|-------------|-----------|-----------------|
| Initial | All nodes | w1, w2, w3, w4, w5, w6 |
| Filter 1 | `nodeSelector: disktype=ssd` | w1, w3, w5 (SSD nodes) |
| Filter 2 | `requiredNodeAffinity: zone=zone-b OR zone-c, disktype=ssd` | **w3, w5** (zone-b/c + SSD) |

**Result**: w3-k8s (zone-b, SSD) and w5-k8s (zone-c, SSD) remain after Stage 2

**Critical**: w1-k8s (zone-a, SSD) is **filtered out** despite being Stage 3's favorite!

#### Stage 3 Scoring is Meaningless (Filter/Score Misalignment)

**Stage 3 Preferences** (what the Pod wants):
- Prefer zone-a nodes (weight: 100) ← **w1 would score 100 points!**

**Reality** (what Filter left):
- w3-k8s: zone-b (not zone-a)
- w5-k8s: zone-c (not zone-a)
- w1-k8s: zone-a **BUT already filtered out!**

**Scoring Table:**

| Node | Zone-a Pref (100) | Total | Status |
|------|-------------------|-------|--------|
| w1-k8s | 100 (zone-a match) | **100** | ❌ **FILTERED OUT** (Stage 2 excluded it) |
| w3-k8s | 0 (zone-b ≠ zone-a) | **0** | ✅ Viable (likely winner) |
| w5-k8s | 0 (zone-c ≠ zone-a) | **0** | ✅ Viable |

**Key Point**:
- **Stage 3 wants w1 the most (100 points) but Stage 2 already filtered it out**
- w3 and w5 both score 0 points
- Stage 3 preferences had **ZERO impact** on the decision
- Final winner: w3 or w5 (other factors decide)
- **Filter/Score Misalignment**: Filter wants zone-b/c, Score wants zone-a
- This is the critical lesson: **Stage 2 Filter dominates over Stage 3 Score preferences**

---

## Comparison: Scenario 97 vs 98 vs 99

| Aspect | Scenario 97 (Zero Nodes) | Scenario 98 (One Node) | Scenario 99 (Two Nodes) |
|--------|--------------------------|------------------------|-------------------------|
| **Stage 2 Result** | 0 nodes | 1 node (w5-k8s) | 2 nodes (w3-k8s, w5-k8s) |
| **Stage 2 Excludes** | All nodes | w1, w2, w3, w4, w6 | **w1-k8s** (Stage 3's favorite!) |
| **Stage 3 Evaluation** | Never evaluated | Not evaluated (unnecessary) | Evaluated but meaningless |
| **Stage 3 Best Node** | N/A | N/A | w1-k8s (100 points) - **already filtered out!** |
| **Stage 3 Remaining Scores** | N/A (no candidates) | N/A (only one option) | w3: 0, w5: 0 |
| **Why Meaningless** | No candidates to score | No choice to make | Best scoring node filtered out |
| **Final Decision** | Unschedulable (Pending) | w5-k8s (forced) | w3-k8s or w5-k8s (other factors) |
| **Pod Status** | Pending forever | Running | Running |
| **Lesson** | Overly restrictive (fail) | Too restrictive filters | **Filter/Score misalignment** |

## Key Takeaways: When Stage 2 Makes Stage 3 Irrelevant

### The Core Principle
**Stage 2 filters can make Stage 3 scoring meaningless when they leave no choice or create scenarios where preferences don't differentiate**

### What We Demonstrated

1. **Scenario 97: No candidates = No scheduling**
   - Stage 2 leaves 0 nodes → Stage 3 is never evaluated
   - Pod stays Pending forever (Unschedulable)
   - Demonstrates overly restrictive Stage 2 filters causing scheduling failure
   - Most extreme case: Stage 2 blocks scheduling entirely

2. **Scenario 98: No choice = No scoring**
   - Stage 2 leaves only 1 node → Stage 3 is bypassed
   - Pod gets scheduled regardless of Stage 3 preferences
   - Demonstrates overly restrictive Stage 2 filters (but still schedulable)

3. **Scenario 99: Filter/Score misalignment = Meaningless preferences**
   - Stage 2 leaves 2 nodes (w3, w5) → Stage 3 evaluates both
   - Stage 3's favorite node (w1, 100 points) was already filtered out by Stage 2
   - Remaining nodes (w3, w5) both score 0 points
   - Demonstrates critical misalignment: **Filter excludes what Score prefers**

4. **Stage 2 dominates when it's too restrictive**
   - Hard constraints (Stage 2) eliminate too many candidates
   - Soft constraints (Stage 3) can't influence the decision
   - Design lesson: Balance Stage 2 filters with Stage 3 preferences

5. **Stage 3 needs candidates that match preferences**
   - If no remaining nodes match preferences, scoring is meaningless
   - Stage 2 and Stage 3 should be aligned for effective scheduling
   - Design lesson: Ensure Stage 2 leaves candidates that can be differentiated by Stage 3

6. **Progression from failure to suboptimal**
   - 0 nodes → Unschedulable (failure)
   - 1 node → Forced placement (no optimization)
   - 2+ nodes but Filter/Score misaligned → Best node filtered out (suboptimal)

### Contrast with stage3/99.score-picks-winner.yaml

In `stage3/`, we show the opposite scenario:
- **Stage 2 leaves 4 nodes** (w1, w2, w3, w4)
- **Stage 3 preferences match multiple nodes** (different scores: 180, 130, 80, 30)
- **Stage 3 scoring decides the winner** (w1-k8s with 180 points)

**The difference**:
- **stage3/99**: Stage 2 is permissive (4 nodes) → Stage 3 matters
- **stage2/97**: Stage 2 is overly restrictive (0 nodes) → Unschedulable
- **stage2/98**: Stage 2 is restrictive (1 node) → Stage 3 bypassed
- **stage2/99**: Stage 2 filters out Stage 3's favorite (w1) → Stage 3 meaningless

## Design Guidelines

### When Stage 2 and Stage 3 Work Well Together

✅ **Good design**:
```yaml
# Stage 2: Filter to multiple candidates
nodeSelector:
  disktype: ssd  # Leaves w1, w3, w5

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: zone
          operator: In
          values: [zone-a, zone-b]  # Leaves w1, w3

    # Stage 3: Differentiate among candidates
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      preference:
        matchExpressions:
        - key: zone
          operator: In
          values: [zone-a]  # w1 gets 100 points, w3 gets 0
```

**Result**: w1 and w3 pass Stage 2, but w1 scores higher (100 vs 0) → w1 wins

### When Stage 2 Makes Stage 3 Meaningless

❌ **Poor design (Scenario 98)**:
```yaml
# Stage 2: Too restrictive - leaves only 1 node
nodeSelector:
  disktype: ssd
tolerations:
- key: gpu  # Only w5 has this
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: zone
          operator: In
          values: [zone-c]  # Combined with above, only w5

    # Stage 3: Preferences don't matter (only 1 candidate)
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      preference:
        matchExpressions:
        - key: zone
          operator: In
          values: [zone-a]  # w5 is zone-c, but it's forced anyway
```

**Problem**: Stage 2 left only w5 → Stage 3 preferences (zone-a) are irrelevant

❌ **Poor design (Scenario 99)**:
```yaml
# Stage 2: Leaves 2 nodes (w1, w3) - both SSD, both zone-a/b
nodeSelector:
  disktype: ssd
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: zone
          operator: In
          values: [zone-a, zone-b]

    # Stage 3: Preferences don't match any remaining nodes
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      preference:
        matchExpressions:
        - key: zone
          operator: In
          values: [zone-c]  # Neither w1 nor w3 is zone-c
    - weight: 50
      preference:
        matchExpressions:
        - key: disktype
          operator: In
          values: [hdd]  # Neither w1 nor w3 is HDD
```

**Problem**: Stage 2 left w1 and w3, but Stage 3 preferences (zone-c, HDD) don't match either → Both score 0

## Cleanup

```bash
# Delete test pods
kubectl delete pod filter-leaves-zero-nodes-unschedulable
kubectl delete pod filter-leaves-one-node-score-bypassed
kubectl delete pod filter-leaves-two-nodes-score-zero

# Or delete by label
kubectl delete pods -l scenario=bypass-stage3
kubectl delete pods -l scenario=bypass-stage3-zero
```

## Further Reading

- Compare with `stage3/README.md` to see when Stage 3 scoring matters
- See `../README.md` for the complete scheduling flow
- Review `../CLAUDE.md` for technical details on Stage 2 Filter plugins
