# Kubernetes Scheduler Deep Dive

Comprehensive demonstration of Kubernetes scheduling across all 7 stages, from admission control to container runtime.

## Overview

This demo provides hands-on examples for understanding how Kubernetes schedules pods, covering:

### Presentation Stages (Stages 0-4)
- **Stage 0**: Admission Control (ResourceQuota, LimitRange, DRA validation)
- **Stage 1**: nodeName (Bypass Scheduler)
- **Stage 2**: Scheduler Filter (Hard Constraints)
- **Stage 3**: Scheduler Score (Soft Constraints)
- **Stage 4**: Binding Cycle (Pod-Node Binding)

### Additional Stages (NOT in presentation - for deeper understanding)
- **Stage 5**: Kubelet Admission (Node-level validation)
- **Stage 6**: Container Runtime (Pod execution)

## Kubernetes Version

- Tested on Kubernetes v1.34

## Directory Structure

```
k8s-scheduler/
├── CLAUDE.md                           # Detailed technical reference
├── comprehensive-complex-scheduling.yaml   # Complex real-world scheduling example
├── stage0/                             # Admission Control demos
│   ├── 00-namespace.yaml
│   ├── 01-limitrange.yaml
│   ├── 02-resourcequota.yaml
│   ├── 03-fail-limitrange.yaml
│   └── 04-pass-limitrange.yaml
├── stage1/                      # nodeName bypass demos
│   ├── 01-pass-nodename-direct.yaml
│   ├── 02-pass-no-nodename.yaml
│   ├── 03-fail-nodename-notfound.yaml
│   ├── 04-pass-nodename-bypass-taint.yaml
│   └── 05-fail-no-nodename-taint.yaml
├── stage2/                      # Filter (hard constraints) demos
│   ├── 01-pass-nodeselector.yaml
│   ├── 02-pass-required-affinity.yaml
│   ├── 03-pass-toleration-required.yaml
│   ├── 04-pass-resource-requests.yaml
│   ├── 05-pass-pod-antiaffinity-1.yaml
│   ├── 06-pass-pod-antiaffinity-2.yaml
│   ├── 07-pass-topology-spread.yaml
│   ├── 08-fail-nodeselector.yaml
│   ├── 09-fail-required-affinity.yaml
│   ├── 10-fail-toleration.yaml
│   ├── 11-fail-resource-requests.yaml
│   ├── 12-fail-topology-spread.yaml
│   ├── 97.filter-leaves-zero-nodes-unschedulable.yaml  # Stage 2 leaves 0 nodes
│   ├── 98.filter-leaves-one-node-score-bypassed.yaml   # Stage 2 leaves 1 node
│   └── 99.filter-leaves-two-nodes-score-zero.yaml      # Stage 2 leaves 2 nodes
├── stage3/                      # Score (soft constraints) demos
│   ├── 01-cache-pod.yaml
│   ├── 02-pass-preferred-nodeaffinity.yaml
│   ├── 03-pass-preferred-podaffinity.yaml
│   ├── 04-pass-prefer-no-schedule.yaml
│   ├── 05-pass-no-prefer-toleration.yaml
│   ├── 06-pass-topology-spread-soft.yaml
│   ├── 07-lowscore-preferred-nodeaffinity.yaml
│   ├── 08-lowscore-preferred-podaffinity.yaml
│   ├── 09-lowscore-topology-spread-soft.yaml
│   ├── 99.score-picks-winner.yaml                          # Stage 3 scoring decides
│   └── taint-node.sh                        # Interactive taint management script
├── stage4/                      # Binding cycle demos
│   ├── 01-block-scheduling-gate.yaml
│   ├── 02-pass-no-scheduling-gate.yaml
│   ├── 03-storageclass.yaml
│   ├── 04-persistentvolume.yaml
│   ├── 05-persistentvolumeclaim.yaml
│   └── 06-pass-volume-late-binding.yaml
├── stage5/                      # Kubelet Admission demos (NOT in presentation)
│   ├── 01-fail-nodeaffinity-mismatch.yaml
│   ├── 02-fail-nodeselector-mismatch.yaml
│   ├── 03-pass-nodeaffinity-match.yaml
│   ├── 04-pass-taint-noexecute-tolerated.yaml
│   ├── 05-pass-taint-noschedule-bypassed.yaml
│   └── 06-fail-insufficient-resources.yaml
└── stage6/                      # Container Runtime demos (NOT in presentation)
    ├── 01-fail-image-pull-error.yaml
    ├── 02-fail-crashloopbackoff.yaml
    ├── 03-fail-invalid-command.yaml
    ├── 04-fail-readiness-probe.yaml
    ├── 05-fail-liveness-probe.yaml
    ├── 06-pass-successful-run.yaml
    └── 07-fail-oom-killed.yaml
```

## Prerequisites

### Cluster Setup

You must have a Kubernetes cluster with the following node configuration:

| Node | Zone | Disk Type | Taints |
|------|------|-----------|--------|
| w1-k8s | zone-a | ssd | - |
| w2-k8s | zone-a | hdd | - |
| w3-k8s | zone-b | ssd | - |
| w4-k8s | zone-b | hdd | - |
| w5-k8s | zone-c | ssd | gpu:nvidia=NoSchedule |
| w6-k8s | zone-c | hdd | maintenance:true=PreferNoSchedule |

> **Note**: Use the `k8s-cluster-builder` directory to set up this cluster automatically.

### Verify Cluster Configuration

```bash
# Check node labels
kubectl get nodes --show-labels | grep -E "zone=|disktype="

# Check node taints
kubectl describe nodes | grep -A 3 "Taints:"
```

## Quick Start

### Stage 0: Admission Control

Test ResourceQuota and LimitRange enforcement at the API server level:

```bash
# Deploy namespace and quotas
kubectl apply -f stage0/00-namespace.yaml
kubectl apply -f stage0/01-limitrange.yaml
kubectl apply -f stage0/02-resourcequota.yaml

# Test: This should FAIL (exceeds LimitRange)
kubectl apply -f stage0/03-fail-limitrange.yaml

# Test: This should PASS
kubectl apply -f stage0/04-pass-limitrange.yaml

# Verify
kubectl get pods -n scheduling-demo
kubectl describe limitrange demo-limits -n scheduling-demo

# Cleanup
kubectl delete namespace scheduling-demo
```

### Stage 1: nodeName (Scheduler Bypass)

Demonstrates how `nodeName` bypasses all scheduler logic:

```bash
# Test: Direct placement with nodeName
kubectl apply -f stage1/01-pass-nodename-direct.yaml

# Test: Scheduler handles placement
kubectl apply -f stage1/02-pass-no-nodename.yaml

# Test: Non-existent node (stays Pending)
kubectl apply -f stage1/03-fail-nodename-notfound.yaml

# Test: Bypass taint check (succeeds WITHOUT toleration - nodeName bypasses ALL checks)
kubectl apply -f stage1/04-pass-nodename-bypass-taint.yaml

# Test: Scheduler enforces taint (fails without toleration)
kubectl apply -f stage1/05-fail-no-nodename-taint.yaml

# Check results
kubectl get pods -o wide

# Cleanup
kubectl delete pods -l 'test in (stage1-nodename,stage1-scheduler,stage1-bypass,stage1-fail)'
```

### Stage 2: Scheduler Filter (Hard Constraints)

All conditions must be satisfied:

```bash
# Deploy all stage2 tests (including comprehensive example)
kubectl apply -f stage2/

# Check successful placements
kubectl get pods -l test=stage2-filter -o wide

# Check failed pods (remain Pending)
kubectl get pods -l test=stage2-fail -o wide

# Describe a failed pod to see why
kubectl describe pod stage2-fail-nodeselector

# Check comprehensive examples (Stage 2 makes Stage 3 meaningless)

# Example 97: Stage 2 leaves 0 nodes (Unschedulable)
kubectl apply -f stage2/97.filter-leaves-zero-nodes-unschedulable.yaml
kubectl get pod filter-leaves-zero-nodes-unschedulable -o wide
# Expected: STATUS = Pending (no node available)
# Note: Stage 3 is never evaluated (no candidates to score)

# Example 98: Stage 2 leaves only 1 node
kubectl apply -f stage2/98.filter-leaves-one-node-score-bypassed.yaml
kubectl get pod filter-leaves-one-node-score-bypassed -o wide
# Expected: w5-k8s (only candidate after Stage 2 Filter)
# Note: Stage 3 preferences (zone-a, HDD) are ignored because w5-k8s is the only option

# Example 99: Stage 2 leaves 2 nodes, but Stage 3's favorite already filtered out
kubectl apply -f stage2/99.filter-leaves-two-nodes-score-zero.yaml
kubectl get pod filter-leaves-two-nodes-score-zero -o wide
# Expected: w3-k8s or w5-k8s (NOT w1-k8s!)
# Note: Stage 3 prefers w1 (zone-a, 100 points), but Stage 2 already filtered it out
#       Filter wants zone-b/c, Score wants zone-a → Misalignment

# Cleanup
kubectl delete pods -l 'test in (stage2-filter,stage2-fail)'
kubectl delete pods -l scenario=bypass-stage3
kubectl delete pods -l scenario=bypass-stage3-zero
```

### Stage 3: Scheduler Score (Soft Constraints)

Preferences influence placement but don't block scheduling:

```bash
# Deploy cache pod first (needed for PodAffinity tests)
kubectl apply -f stage3/01-cache-pod.yaml

# Deploy pass tests (high scores - good matches)
kubectl apply -f stage3/02-pass-preferred-nodeaffinity.yaml
kubectl apply -f stage3/03-pass-preferred-podaffinity.yaml
kubectl apply -f stage3/04-pass-prefer-no-schedule.yaml
kubectl apply -f stage3/05-pass-no-prefer-toleration.yaml
kubectl apply -f stage3/06-pass-topology-spread-soft.yaml

# Deploy lowscore tests (low scores - poor matches)
kubectl apply -f stage3/07-lowscore-preferred-nodeaffinity.yaml
kubectl apply -f stage3/08-lowscore-preferred-podaffinity.yaml
kubectl apply -f stage3/09-lowscore-topology-spread-soft.yaml

# All pods should be Running, but on different nodes
kubectl get pods -l 'test in (stage3-score,stage3-lowscore)' -o wide

# Compare: Pass vs Lowscore placements
kubectl get pod stage3-pass-preferred-podaffinity -o wide
kubectl get pod stage3-lowscore-preferred-podaffinity -o wide

# Check comprehensive example (Stage 3 actually matters)
kubectl get pod score-picks-winner -o wide
# Expected: w1-k8s (highest score: 180 points)
# Scoring: w1(180) > w2(130) > w3(80) > w4(30)
# Note: Stage 2 left 4 candidates, Stage 3 picked the best

# Interactive taint management (change Stage 3 winner)
cd stage3
./taint-node.sh
# Use fzf to select a node and apply taints
# Observe how taints affect Stage 3 scoring and winner selection

# Cleanup
kubectl delete pods -l 'test in (stage3-score,stage3-lowscore)'
kubectl delete pod score-picks-winner
kubectl delete pod cache-pod
```

### Stage 4: Binding Cycle

Control the final binding phase:

```bash
# Deploy storage infrastructure
kubectl apply -f stage4/03-storageclass.yaml
kubectl apply -f stage4/04-persistentvolume.yaml
kubectl apply -f stage4/05-persistentvolumeclaim.yaml

# Deploy pods
kubectl apply -f stage4/01-block-scheduling-gate.yaml
kubectl apply -f stage4/02-pass-no-scheduling-gate.yaml
kubectl apply -f stage4/06-pass-volume-late-binding.yaml

# Check: Gated pod should be "SchedulingGated"
kubectl get pod stage4-block-scheduling-gate -o wide

# Check: schedulingGates are present
kubectl get pod stage4-block-scheduling-gate -o jsonpath='{.spec.schedulingGates}'

# Unblock the gated pod
kubectl patch pod stage4-block-scheduling-gate \
  --type=json -p='[{"op": "remove", "path": "/spec/schedulingGates"}]'

# Verify: All pods should now be Running
kubectl get pods -l 'test in (stage4-pass,stage4-block)' -o wide

# Check: PVC should be Bound
kubectl get pvc

# Cleanup
kubectl delete pods -l 'test in (stage4-pass,stage4-block)'
kubectl delete pvc demo-pvc
kubectl delete pv demo-pv-w1
kubectl delete sc late-binding-sc
```

---

## Additional Stages (NOT in Presentation)

**Note**: Stage 5 and Stage 6 are NOT covered in the KubeCon presentation. These stages are included for deeper understanding of what happens after the scheduler completes its work.

### Stage 5: Kubelet Admission (Node-level Validation)

Demonstrates kubelet-level validation that occurs even when the scheduler is bypassed:

```bash
# Test: nodeAffinity validation by kubelet (FAIL)
kubectl apply -f stage5/01-fail-nodeaffinity-mismatch.yaml
kubectl get pod stage5-fail-nodeaffinity -o wide
# Expected: Status = NodeAffinity (Failed)
# Message: "Predicate NodeAffinity failed"

# Test: nodeSelector validation by kubelet (FAIL)
kubectl apply -f stage5/02-fail-nodeselector-mismatch.yaml
kubectl get pod stage5-fail-nodeselector -o wide
# Expected: Status = NodeAffinity (Failed)

# Test: nodeAffinity matches target node (PASS)
kubectl apply -f stage5/03-pass-nodeaffinity-match.yaml
kubectl get pod stage5-pass-nodeaffinity -o wide
# Expected: Status = Running on w5-k8s

# Test: NoExecute taint validated by kubelet (PASS with toleration)
kubectl apply -f stage5/04-pass-taint-noexecute-tolerated.yaml
kubectl get pod stage5-pass-noexecute-taint -o wide
# Expected: Status = Running on w6-k8s

# Test: NoSchedule taint bypassed by kubelet (PASS without toleration)
kubectl apply -f stage5/05-pass-taint-noschedule-bypassed.yaml
kubectl get pod stage5-pass-noschedule-bypassed -o wide
# Expected: Status = Running on w5-k8s (despite gpu:NoSchedule taint)

# Test: Resource availability check (may FAIL if insufficient resources)
kubectl apply -f stage5/06-fail-insufficient-resources.yaml
kubectl get pod stage5-fail-insufficient-resources -o wide
# Expected: Status = Failed or OutOfmemory (if node lacks 1000Gi memory)

# Check detailed events
kubectl describe pod stage5-fail-nodeaffinity
kubectl describe pod stage5-pass-noschedule-bypassed

# Cleanup
kubectl delete pods -l test=stage5-kubelet-admission
```

**Key Insights for Stage 5:**
- Kubelet validates `nodeAffinity` and `nodeSelector` even when `nodeName` bypasses scheduler
- `NoExecute` taints are validated by kubelet (admission + eviction)
- `NoSchedule` taints are NOT validated by kubelet (scheduler-only)
- Resource availability is re-checked at kubelet admission time

### Stage 6: Container Runtime (Pod Execution)

Demonstrates container runtime failures that occur after successful scheduling and kubelet admission:

```bash
# Test: Image pull failure (FAIL)
kubectl apply -f stage6/01-fail-image-pull-error.yaml
kubectl get pod stage6-fail-image-pull -o wide
# Expected: Status = ImagePullBackOff or ErrImagePull

# Test: Container crash (FAIL)
kubectl apply -f stage6/02-fail-crashloopbackoff.yaml
kubectl get pod stage6-fail-crashloop -o wide
# Expected: Status = CrashLoopBackOff

# Test: Invalid container command (FAIL)
kubectl apply -f stage6/03-fail-invalid-command.yaml
kubectl get pod stage6-fail-invalid-command -o wide
# Expected: Status = CrashLoopBackOff

# Test: Readiness probe failure (Running but not Ready)
kubectl apply -f stage6/04-fail-readiness-probe.yaml
kubectl get pod stage6-fail-readiness -o wide
# Expected: Status = Running, READY = 0/1

# Test: Liveness probe failure (Gets restarted)
kubectl apply -f stage6/05-fail-liveness-probe.yaml
sleep 60
kubectl get pod stage6-fail-liveness -o wide
# Expected: RESTARTS > 0 (container killed and restarted)

# Test: Successful execution (PASS)
kubectl apply -f stage6/06-pass-successful-run.yaml
kubectl get pod stage6-pass-successful -o wide
# Expected: Status = Running, READY = 1/1

# Test: OOMKilled (FAIL)
kubectl apply -f stage6/07-fail-oom-killed.yaml
sleep 10
kubectl get pod stage6-fail-oom -o wide
# Expected: Status = OOMKilled or CrashLoopBackOff
# Last State: Terminated, Reason: OOMKilled, Exit Code: 137

# Check detailed events and container status
kubectl describe pod stage6-fail-image-pull
kubectl describe pod stage6-fail-liveness
kubectl describe pod stage6-fail-oom

# Cleanup
kubectl delete pods -l test=stage6-container-runtime
```

**Key Insights for Stage 6:**
- Image pull happens after all scheduling decisions are made
- Container failures (crash, invalid command) occur at runtime, not scheduling time
- Health probes (readiness/liveness) operate after container starts
- Resource limits (memory) are enforced by container runtime/kernel, not scheduler
- All Stage 6 failures occur AFTER the Pod has been successfully scheduled and admitted

## Standard YAML Field Ordering

For consistency and readability, all Pod specs in this demo follow this standard field order:

```yaml
spec:
  # 1. Scheduling-related fields (before containers)
  nodeName:                    # Stage 1: Bypass scheduler
  nodeSelector:                # Stage 2: Filter by node labels
  tolerations:                 # Stage 2: Filter (allow tainted nodes)
  affinity:                    # Stage 2: Filter (required) / Stage 3: Score (preferred)
  topologySpreadConstraints:   # Stage 2: Filter / Stage 3: Score
  schedulingGates:             # Stage 4: Block binding until removed

  # 2. Container definition
  containers:

  # 3. Runtime configuration (after containers)
  volumes:
  securityContext:
  imagePullSecrets:
  dnsPolicy:
```

**Why this order matters:**
- **Logical flow**: Scheduling decisions → Container definition → Runtime setup
- **Readability**: Related scheduling fields are grouped together
- **Stage clarity**: Shows which stage handles each field

**Key ordering rule:**
- Stage 2 Filter fields grouped together: `nodeSelector` → `tolerations` → `affinity` (required)
- All scheduling fields come **before** `containers`
- Runtime fields (volumes, etc.) come **after** `containers`

## Key Concepts

### Presentation Stages (0-4)

#### Stage 0: Admission Control
- Validates resource requests before reaching scheduler
- Enforces namespace quotas (ResourceQuota) and container limits (LimitRange)
- Validates ResourceClaims for DRA (when applicable)
- Rejects invalid pods immediately at API server level

#### Stage 1: nodeName
- **Bypasses scheduler logic** (Filter and Score stages)
- Directly assigns pod to specified node
- **Does NOT bypass kubelet admission** (see Stage 5)
- Scheduler ignores: nodeSelector, affinity, tolerations
- **Important**: nodeName bypasses taint checks - pod can be scheduled on tainted nodes WITHOUT tolerations
- Use case: Manual placement, testing

#### Stage 2: Filter (Hard Constraints)
- **All** conditions must pass
- Filtering criteria:
  - NodeSelector
  - NodeAffinity (required)
  - Taints/Tolerations
  - Resource requests
  - PodAffinity/PodAntiAffinity (required)
  - TopologySpreadConstraints (whenUnsatisfiable: DoNotSchedule)
- Failure = Pod stays Pending

#### Stage 3: Score (Soft Constraints)
- **Preferences** influence placement
- Scoring criteria:
  - NodeAffinity (preferred)
  - PodAffinity/PodAntiAffinity (preferred)
  - PreferNoSchedule taints
  - TopologySpreadConstraints (whenUnsatisfiable: ScheduleAnyway)
  - Resource balancing
- Failure = Still schedules, but on less optimal node

#### Stage 4: Binding Cycle
Five extension points:
1. **Reserve**: Reserve resources (volumes, devices)
2. **Permit**: Gate/approval (schedulingGates)
3. **PreBind**: Prepare resources (volume binding)
4. **Bind**: Update API server
5. **PostBind**: Notifications

### Additional Stages (NOT in Presentation)

#### Stage 5: Kubelet Admission
- **Node-level validation** before accepting Pod
- Validates even when `nodeName` bypasses scheduler
- Validation checks:
  - nodeAffinity and nodeSelector (ENFORCED)
  - NoExecute taints (ENFORCED)
  - NoSchedule taints (NOT enforced - scheduler-only)
  - Resource availability (re-checked)
- Failure = Pod rejected by kubelet with status like "NodeAffinity"

#### Stage 6: Container Runtime
- **Container execution** after scheduling and admission
- Runtime operations:
  - Image pull from registry
  - Container creation and startup
  - Health checks (readiness/liveness probes)
  - Resource limit enforcement (OOM killer)
- Failures occur AFTER successful scheduling:
  - ImagePullBackOff: Image not found
  - CrashLoopBackOff: Container crashes
  - OOMKilled: Memory limit exceeded
  - Not Ready: Readiness probe fails

## Comprehensive Tests

Three comprehensive examples demonstrate how scheduling stages interact:

### 1. Complex Real-World Scheduling (comprehensive-complex-scheduling.yaml)

Demonstrates a realistic production scenario with multiple constraints working together:

```bash
# Deploy cache pod first (needed for PodAffinity)
kubectl apply -f stage3/01-cache-pod.yaml

# Deploy complex scheduling test
kubectl apply -f comprehensive-complex-scheduling.yaml

# Check placement
kubectl get pod comprehensive-scheduling-test -n scheduling-demo -o wide
# Expected: w1-k8s (passes Stage 2 filters, highest Stage 3 score)

# Review how all constraints work together
kubectl describe pod comprehensive-scheduling-test -n scheduling-demo

# Cleanup
kubectl delete pod comprehensive-scheduling-test -n scheduling-demo
kubectl delete pod cache-pod -n scheduling-demo
```

This pod combines:
- **Stage 2 (Hard)**: nodeSelector (ssd), required NodeAffinity (zone-a/b), NoSchedule toleration (gpu), PodAntiAffinity, TopologySpread, Resource requests
- **Stage 3 (Soft)**: preferred NodeAffinity (zone-a), preferred PodAffinity (cache), PreferNoSchedule toleration (maintenance)
- **Stage 4**: Normal binding

**Key lesson**: Real-world pods often use multiple Stage 2 and Stage 3 constraints together. Stage 2 narrows candidates (w1, w3), then Stage 3 picks the best (w1).

### 2. Stage 2 Makes Stage 3 Meaningless

Three scenarios demonstrate when Stage 2 filters make Stage 3 scoring irrelevant:

#### 2a. Zero Nodes Remaining (stage2/97.filter-leaves-zero-nodes-unschedulable.yaml)

When hard constraints are too restrictive, no nodes pass and the Pod stays Pending:

```bash
# Deploy the test
kubectl apply -f stage2/97.filter-leaves-zero-nodes-unschedulable.yaml

# Check status
kubectl get pod filter-leaves-zero-nodes-unschedulable -o wide
# Expected: STATUS = Pending (no node available)

# Review why scheduling failed
kubectl describe pod filter-leaves-zero-nodes-unschedulable
# Note: Stage 2 Filter left 0 candidates (requires zone-c + SSD + gpu toleration)
# Note: Stage 3 is never evaluated (no candidates to score)

# Cleanup
kubectl delete pod filter-leaves-zero-nodes-unschedulable
```

**Key lesson**: When Stage 2 leaves 0 nodes, Stage 3 is never evaluated and the Pod stays Unschedulable.

#### 2b. One Node Remaining (stage2/98.filter-leaves-one-node-score-bypassed.yaml)

When hard constraints leave only one candidate, soft constraints are completely bypassed:

```bash
# Deploy the test
kubectl apply -f stage2/98.filter-leaves-one-node-score-bypassed.yaml

# Check placement
kubectl get pod filter-leaves-one-node-score-bypassed -o wide
# Expected: w5-k8s (zone-c, SSD, GPU taint)

# Review the contradiction
kubectl describe pod filter-leaves-one-node-score-bypassed
# Note: Stage 3 prefers zone-a + HDD
# But: w5-k8s is zone-c + SSD (opposite!)
# Why: Stage 2 Filter left only w5-k8s as a candidate
#      Stage 3 preferences had ZERO impact (no choice to make)

# Cleanup
kubectl delete pod filter-leaves-one-node-score-bypassed
```

**Key lesson**: When Stage 2 leaves only 1 node, Stage 3 scoring is completely bypassed.

#### 2c. Two Nodes, Filter/Score Misalignment (stage2/99.filter-leaves-two-nodes-score-zero.yaml)

When hard constraints exclude what soft constraints prefer most:

```bash
# Deploy the test
kubectl apply -f stage2/99.filter-leaves-two-nodes-score-zero.yaml

# Check placement
kubectl get pod filter-leaves-two-nodes-score-zero -o wide
# Expected: w3-k8s or w5-k8s (NOT w1-k8s!)

# Review the misalignment
kubectl describe pod filter-leaves-two-nodes-score-zero
# Stage 2 Filter: Requires zone-b OR zone-c → w3, w5 remain
# Stage 3 Score: Prefers zone-a (100 points) → w1 would be best
# Misalignment: w1 (Stage 3's favorite) was filtered out by Stage 2
# Result: w3 and w5 both score 0 points
# Final decision: Based on other factors (w1 cannot be selected)

# Cleanup
kubectl delete pod filter-leaves-two-nodes-score-zero
```

**Key lesson**: When Stage 2 filters out Stage 3's preferred nodes, scoring becomes meaningless. Filter decisions dominate over Score preferences.

**Comparison**:
- **97**: 0 nodes left → Stage 3 never evaluated (Unschedulable)
- **98**: 1 node left → Stage 3 not evaluated (no choice)
- **99**: 2 nodes left → Stage 3's favorite (w1) filtered out → meaningless

**Location**: All three examples are in `stage2/` because they demonstrate the **power of Stage 2 filters** - when Stage 2 is too restrictive or misaligned with Stage 3, Stage 3 becomes irrelevant.

### 3. Stage 3 Actually Matters (stage3/99.score-picks-winner.yaml)

Demonstrates when soft constraints determine the final placement:

```bash
# Deploy the test (from stage3 directory)
kubectl apply -f stage3/99.score-picks-winner.yaml

# Check placement
kubectl get pod score-picks-winner -o wide
# Expected: w1-k8s (highest score: 180 points)

# Review the scoring
kubectl describe pod score-picks-winner
# Scoring breakdown:
# - w1-k8s: zone-a (100) + SSD (80) = 180 points ← WINNER!
# - w2-k8s: zone-a (100) + HDD (30) = 130 points
# - w3-k8s: zone-b (0) + SSD (80) = 80 points
# - w4-k8s: zone-b (0) + HDD (30) = 30 points

# Change the winner by applying taints
cd stage3
./taint-node.sh
# Select w1-k8s and apply NoSchedule taint
# Redeploy: kubectl delete pod score-picks-winner
#           kubectl apply -f 99.score-picks-winner.yaml
# New winner: w2-k8s (130 points, w1 filtered out)

# Cleanup
kubectl delete pod score-picks-winner
```

**Key lesson**: When Stage 2 leaves multiple candidates, Stage 3 picks the best match.

**Location**: This example is in `stage3/` because it demonstrates the **importance of Stage 3 scoring** - when Stage 2 allows multiple nodes, Stage 3 decides the winner.

**Interactive Tool**: Use `taint-node.sh` to dynamically change node taints and observe how it affects the Stage 3 winner selection.

### Comparison Summary

| Test | Location | Stage 2 Candidates | Stage 3 Best Node | Stage 3 Impact | Final Node | Scenario |
|------|----------|-------------------|-------------------|----------------|------------|----------|
| comprehensive-complex-scheduling.yaml | Root | w1, w3 (multiple filters) | w1 (available) | **Picks the best** | w1-k8s | Real-world: Both stages matter |
| 97.filter-leaves-zero-nodes-unschedulable.yaml | stage2/ | None (0 nodes) | N/A | **Never evaluated** | None (Pending) | Stage 2 too restrictive: Fail |
| 98.filter-leaves-one-node-score-bypassed.yaml | stage2/ | Only w5-k8s | N/A | **Not evaluated** | w5-k8s (forced) | Stage 2 too strong: No choice |
| 99.filter-leaves-two-nodes-score-zero.yaml | stage2/ | w3, w5 (zone-b/c) | **w1 (filtered out!)** | **Meaningless** | w3-k8s or w5-k8s | Filter excludes Score's favorite |
| 99.score-picks-winner.yaml | stage3/ | w1, w2, w3, w4 | w1 (available) | **Decides placement** | w1-k8s (best score) | Stage 3 is the decider |

**Learning Path**:
1. Start with individual stage examples (stage0/ → stage1/ → stage2/ → stage3/ → stage4/)
2. Each stage includes comprehensive examples:
   - stage2: 97, 98, 99 (when Stage 3 becomes meaningless)
   - stage3: 99 (when Stage 3 decides the winner)
3. Finish with the root comprehensive-complex-scheduling.yaml for the complete picture

## Troubleshooting

### Pod stays Pending

```bash
# Check events
kubectl describe pod <pod-name>

# Look for FailedScheduling events
kubectl get events --sort-by='.lastTimestamp' | grep FailedScheduling
```

### Common issues by stage

**Presentation Stages:**
- **Stage 0**: ResourceQuota or LimitRange violations (rejected before scheduling)
- **Stage 1**: nodeName to non-existent node (stays Pending)
- **Stage 2**: Missing toleration for tainted node (no nodes available)
- **Stage 2**: NodeSelector doesn't match any node (no nodes available)
- **Stage 2**: Insufficient resources on all nodes (no nodes available)
- **Stage 3**: All pods schedule successfully (soft constraints don't block)
- **Stage 4**: schedulingGates blocking binding (SchedulingGated status)

**Additional Stages (NOT in presentation):**
- **Stage 5**: nodeAffinity mismatch (Status: NodeAffinity, rejected by kubelet)
- **Stage 5**: nodeSelector mismatch (Status: NodeAffinity, rejected by kubelet)
- **Stage 5**: NoExecute taint without toleration (rejected by kubelet)
- **Stage 6**: Image pull failure (Status: ImagePullBackOff or ErrImagePull)
- **Stage 6**: Container crash (Status: CrashLoopBackOff, check logs)
- **Stage 6**: OOMKilled (Status: OOMKilled, increase memory limits)
- **Stage 6**: Readiness probe failure (Running but 0/1 Ready)

## Advanced Topics

### DRA (Dynamic Resource Allocation)

Dynamic Resource Allocation is a Kubernetes feature for managing specialized hardware resources (GPUs, FPGAs, etc.) through a more flexible API than traditional resource requests.

**Why not included in this demo:**
- Requires DRA-compatible drivers (e.g., NVIDIA GPU Operator with DRA support)
- Requires actual hardware devices or device plugins
- Complex setup beyond basic Kubernetes cluster requirements
- Not suitable for VM-based demo environments

**Where to learn more:**
- DRA examples and detailed documentation are available in `CLAUDE.md`
- DRA operates across multiple scheduling stages (Stage 0 Validation, Stage 2 Filter, Stage 3 Score, Stage 4 Binding)
- Feature is enabled by default in Kubernetes v1.34+ (core API stable; some features may require feature gates)

**If you want to test DRA:**
1. Install a DRA-compatible driver in your cluster
2. Verify ResourceSlices exist: `kubectl get resourceslices`
3. Create DeviceClass for your devices
4. Refer to examples in `CLAUDE.md`

### Custom Scheduler

To test with a custom scheduler:

```yaml
spec:
  schedulerName: my-custom-scheduler
```

## File Naming Convention

- **pass**: Expected to succeed
- **fail**: Expected to fail (Pending)
- **block**: Temporarily blocked (SchedulingGated)
- **lowscore**: Succeeds but with lower score

## Documentation

See `CLAUDE.md` for detailed technical reference including:
- Complete scheduling flow diagrams
- Extension point documentation
- Advanced configuration examples

## Best Practices

1. **Start with Stage 0**: Understand admission control first
2. **Progress sequentially**: Each stage builds on previous concepts
3. **Compare pass/fail**: Learn from both successes and failures
4. **Use kubectl describe**: Events explain scheduling decisions
5. **Clean up between tests**: Avoid resource conflicts

## References

- [Kubernetes Scheduling Framework](https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/)
- [Pod Scheduling Readiness](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-scheduling-readiness/)
- [Dynamic Resource Allocation](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/)

## License

Educational material for KubeCon NA 2025.
