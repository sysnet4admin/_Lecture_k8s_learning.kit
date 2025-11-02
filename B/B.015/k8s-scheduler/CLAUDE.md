# ============================================================
# Kubernetes Scheduling 5-Stage Comparison Sample
# Version: Kubernetes v1.31+ (v1.34 compatible)
# ============================================================
#
# Scheduling Flow:
# Stage 0: Admission Control (ResourceQuota, LimitRange, DRA validation)
# Stage 1: nodeName (Bypass Scheduler)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Scheduling Cycle (Serial Execution)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 2: Scheduler Filter (Hard Constraints)
# Stage 3: Scheduler Score (Soft Constraints)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Binding Cycle (Can run concurrently across different Pods)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 4: Binding (Reserve → Permit → PreBind → Bind → PostBind)
#
# DRA (Dynamic Resource Allocation) operates across stages:
# - Stage 0: ResourceClaim validation (API admission & resourceclaim-controller)
# - Stage 2: ResourceSlice filtering for device availability
# - Stage 3: Device allocation scoring
# - Stage 4: ResourceClaim allocation updates (Reserve/PreBind)
# ============================================================

# ------------------------------------------------------------
# Prerequisites: Node Labels and Taints Setup (6-node environment)
# ------------------------------------------------------------
# Node configuration:
# w1-k8s: zone-a, ssd
# w2-k8s: zone-a, hdd
# w3-k8s: zone-b, ssd
# w4-k8s: zone-b, hdd
# w5-k8s: zone-c, ssd, gpu taint
# w6-k8s: zone-c, hdd, maintenance taint

---
# ============================================================
# Stage 0: ResourceQuota & LimitRange (Admission Control)
# ============================================================

apiVersion: v1
kind: Namespace
metadata:
  name: scheduling-demo

---
# LimitRange: Per-container resource limits
apiVersion: v1
kind: LimitRange
metadata:
  name: demo-limits
  namespace: scheduling-demo
spec:
  limits:
  - max:
      memory: "2Gi"
      cpu: "2000m"
    min:
      memory: "4Mi"
      cpu: "5m"
    default:
      memory: "128Mi"
      cpu: "100m"
    defaultRequest:
      memory: "16Mi"
      cpu: "10m"
    type: Container

---
# ResourceQuota: Namespace-wide resource limits
apiVersion: v1
kind: ResourceQuota
metadata:
  name: demo-quota
  namespace: scheduling-demo
spec:
  hard:
    requests.cpu: "10"
    requests.memory: "20Gi"
    limits.cpu: "20"
    limits.memory: "40Gi"
    pods: "20"

---
# ============================================================
# Stage 0 Test: LimitRange Violation (Expected to Fail)
# ============================================================

apiVersion: v1
kind: Pod
metadata:
  name: stage0-fail-limitrange
  namespace: scheduling-demo
  labels:
    test: stage0-fail
spec:
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "3Gi"  # Exceeds LimitRange max(2Gi) -> Rejected immediately
        cpu: "500m"

---
# Stage 0 Test: LimitRange Pass
apiVersion: v1
kind: Pod
metadata:
  name: stage0-pass-limitrange
  namespace: scheduling-demo
  labels:
    test: stage0-pass
spec:
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "1Gi"  # Within LimitRange
        cpu: "500m"

---
# ============================================================
# Stage 1: nodeName (Bypass Scheduler)
# ============================================================

# Stage 1 Test: nodeName specified (Skip scheduler)
apiVersion: v1
kind: Pod
metadata:
  name: stage1-nodename-direct
  labels:
    test: stage1-nodename
spec:
  nodeName: w5-k8s  # Direct placement on w5-k8s node
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"
  # Note: The following conditions are ignored
  nodeSelector:
    disktype: ssd  # Ignored
  tolerations:
  - key: gpu
    operator: Equal
    value: nvidia
    effect: NoSchedule  # Ignored

---
# Stage 1 Comparison: No nodeName (Use scheduler)
apiVersion: v1
kind: Pod
metadata:
  name: stage1-no-nodename
  labels:
    test: stage1-scheduler
spec:
  # No nodeName -> Scheduler handles it
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"
  nodeSelector:
    disktype: ssd  # Scheduler processes this

---
# ============================================================
# Stage 2: Scheduler Filter (Hard Constraints)
# ============================================================
# Note: DRA ResourceSlice filtering also happens in this stage
# when ResourceClaims are used

# Stage 2 Test: Filter by NodeSelector
apiVersion: v1
kind: Pod
metadata:
  name: stage2-nodeselector
  namespace: scheduling-demo
  labels:
    test: stage2-filter
    component: nodeselector
spec:
  nodeSelector:
    disktype: ssd  # Only nodes with disktype=ssd
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 2 Test: Filter by Required NodeAffinity
apiVersion: v1
kind: Pod
metadata:
  name: stage2-required-affinity
  namespace: scheduling-demo
  labels:
    test: stage2-filter
    component: node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: zone
            operator: In
            values:
            - zone-a
            - zone-b  # Only zone-a or zone-b nodes (w1-w4)
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 2 Test: Filter by Taints/Tolerations
apiVersion: v1
kind: Pod
metadata:
  name: stage2-toleration-required
  namespace: scheduling-demo
  labels:
    test: stage2-filter
    component: toleration
spec:
  tolerations:
  - key: gpu
    operator: Equal
    value: nvidia
    effect: NoSchedule  # Tolerate NoSchedule taint (required)
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 2 Test: Filter by Resource Requests
apiVersion: v1
kind: Pod
metadata:
  name: stage2-resource-requests
  namespace: scheduling-demo
  labels:
    test: stage2-filter
    component: resources
spec:
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "1Gi"    # Only nodes with sufficient memory
        cpu: "1000m"     # Only nodes with sufficient CPU
      limits:
        memory: "2Gi"
        cpu: "2000m"

---
# Stage 2 Test: Filter by Required PodAntiAffinity
apiVersion: v1
kind: Pod
metadata:
  name: stage2-pod-antiaffinity-1
  namespace: scheduling-demo
  labels:
    test: stage2-filter
    component: pod-antiaffinity
    app: web
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: web
        topologyKey: kubernetes.io/hostname  # No app=web Pods on same host
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 2 Comparison: Second web Pod (should be placed on different node)
apiVersion: v1
kind: Pod
metadata:
  name: stage2-pod-antiaffinity-2
  namespace: scheduling-demo
  labels:
    test: stage2-filter
    component: pod-antiaffinity
    app: web
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: web
        topologyKey: kubernetes.io/hostname
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 2 Test: TopologySpreadConstraints (Hard)
apiVersion: v1
kind: Pod
metadata:
  name: stage2-topology-spread-1
  namespace: scheduling-demo
  labels:
    test: stage2-filter
    component: topology-spread
    app: distributed
spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: zone
    whenUnsatisfiable: DoNotSchedule  # Required constraint
    labelSelector:
      matchLabels:
        app: distributed
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# ============================================================
# DRA (Dynamic Resource Allocation) Test
# ============================================================
# DRA spans multiple stages:
# - Stage 0: ResourceClaim admission validation
# - Stage 2: ResourceSlice filtering (device availability)
# - Stage 3: Device allocation scoring
# - Stage 4: Allocation finalization (Reserve/PreBind)
#
# Prerequisites for DRA testing:
# 1. DRA feature gate enabled (default in v1.34+; core API stable, some features may require feature gates)
# 2. DRA driver installed (e.g., gpu-driver)
# 3. DeviceClass created
# 4. ResourceSlices published by driver
#
# Example DRA workflow:
# Step 1: Create DeviceClass (done by cluster admin/driver)
# Step 2: Create ResourceClaimTemplate (references DeviceClass)
# Step 3: Create Pod using ResourceClaimTemplate
# Step 4: Scheduler filters nodes with matching devices (Stage 2)
# Step 5: Scheduler scores nodes based on device availability (Stage 3)
# Step 6: ResourceClaim gets allocated to selected node (Stage 4)

# Example DeviceClass (must be created before ResourceClaim)
# apiVersion: resource.k8s.io/v1
# kind: DeviceClass
# metadata:
#   name: gpu.example.com
# spec:
#   selectors:
#   - cel:
#       expression: device.driver == 'gpu.example.com'

# Example ResourceClaimTemplate for DRA
# apiVersion: resource.k8s.io/v1
# kind: ResourceClaimTemplate
# metadata:
#   name: gpu-claim-template
#   namespace: scheduling-demo
# spec:
#   spec:
#     devices:
#       requests:
#       - name: gpu-req
#         deviceClassName: gpu.example.com
#         selectors:
#         - cel:
#             expression: device.attributes["gpu.example.com"].memory > "8Gi"

# Example Pod using DRA ResourceClaimTemplate
# apiVersion: v1
# kind: Pod
# metadata:
#   name: dra-test-pod
#   namespace: scheduling-demo
#   labels:
#     test: dra
# spec:
#   resourceClaims:
#   - name: gpu-claim
#     resourceClaimTemplateName: gpu-claim-template
#   containers:
#   - name: app
#     image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
#     resources:
#       requests:
#         memory: "16Mi"
#         cpu: "10m"
#       claims:
#       - name: gpu-claim

# Note: To test DRA in your cluster:
# 1. Install a DRA-compatible driver (e.g., NVIDIA GPU Operator with DRA support)
# 2. Verify ResourceSlices are created: kubectl get resourceslices
# 3. Create DeviceClass for your devices
# 4. Uncomment and apply the above ResourceClaimTemplate and Pod
# 5. Observe scheduling: kubectl describe pod dra-test-pod -n scheduling-demo
# 6. Check allocation: kubectl get resourceclaim -n scheduling-demo

---
# ============================================================
# Stage 3: Scheduler Score (Soft Constraints)
# ============================================================
# Note: DRA device allocation scoring also happens in this stage

# Deploy cache Pod first (for PodAffinity test)
apiVersion: v1
kind: Pod
metadata:
  name: cache-pod
  namespace: scheduling-demo
  labels:
    tier: cache
spec:
  containers:
  - name: redis
    image: redis:7-alpine
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 3 Test: Preferred NodeAffinity (Preference)
apiVersion: v1
kind: Pod
metadata:
  name: stage3-preferred-nodeaffinity
  namespace: scheduling-demo
  labels:
    test: stage3-score
    component: node-affinity
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100  # Strongly prefer zone-a (w1, w2)
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - zone-a
      - weight: 80   # Moderately prefer zone-c (w5, w6)
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - zone-c
      - weight: 50   # Slightly prefer SSD (w1, w3, w5)
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 3 Test: Preferred PodAffinity (Prefer same node as cache)
apiVersion: v1
kind: Pod
metadata:
  name: stage3-preferred-podaffinity
  namespace: scheduling-demo
  labels:
    test: stage3-score
    component: pod-affinity
spec:
  affinity:
    podAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100  # Prefer same node as cache Pod
        podAffinityTerm:
          labelSelector:
            matchLabels:
              tier: cache
          topologyKey: kubernetes.io/hostname
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 3 Test: PreferNoSchedule Toleration
apiVersion: v1
kind: Pod
metadata:
  name: stage3-prefer-no-schedule
  namespace: scheduling-demo
  labels:
    test: stage3-score
    component: prefer-no-schedule
spec:
  # Can be placed without toleration but with lower score
  # With toleration, no score penalty
  tolerations:
  - key: maintenance
    operator: Equal
    value: "true"
    effect: PreferNoSchedule  # Handled in Score stage via TaintToleration plugin
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 3 Comparison: No PreferNoSchedule Toleration
apiVersion: v1
kind: Pod
metadata:
  name: stage3-no-prefer-toleration
  namespace: scheduling-demo
  labels:
    test: stage3-score
    component: no-prefer-toleration
spec:
  # No toleration -> Nodes with maintenance taint get lower score
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 3 Test: TopologySpreadConstraints (Soft)
apiVersion: v1
kind: Pod
metadata:
  name: stage3-topology-spread-soft-1
  namespace: scheduling-demo
  labels:
    test: stage3-score
    component: topology-soft
    app: flexible-distributed
spec:
  topologySpreadConstraints:
  - maxSkew: 2
    topologyKey: zone
    whenUnsatisfiable: ScheduleAnyway  # Preference (schedule even if unsatisfied)
    labelSelector:
      matchLabels:
        app: flexible-distributed
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# ============================================================
# Stage 4: Binding Cycle (Pod-Node Binding)
# ============================================================
# The Binding Cycle finalizes the scheduling decision by binding
# the Pod to the selected node. It consists of 5 extension points:
#
# 1. Reserve: Reserve resources on the node (e.g., volumes, DRA devices)
# 2. Permit: Gate/approve Pod scheduling (can delay binding)
# 3. PreBind: Prepare resources before binding (e.g., mount volumes)
# 4. Bind: Actually bind Pod to node (update API server)
# 5. PostBind: Cleanup/notifications after binding
#
# These extension points are for plugin developers. Users can
# influence this stage through:
# - schedulingGates: Control Permit extension point
# - volumeBindingMode: Control Reserve/PreBind extension points
# - Custom admission webhooks: Inject schedulingGates
# ============================================================

# Stage 4 Test: Pod with schedulingGates (Blocked at Permit)
apiVersion: v1
kind: Pod
metadata:
  name: stage4-scheduling-gate-blocked
  namespace: scheduling-demo
  labels:
    test: stage4-binding
    component: scheduling-gate
spec:
  schedulingGates:
  - name: example.com/approval-required  # Blocks at Permit extension point
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"
# Expected: Pod status shows "SchedulingGated" condition
# Scheduler selects a node but doesn't proceed to Bind until gate is removed
#
# To unblock and allow binding:
# kubectl patch pod stage4-scheduling-gate-blocked -n scheduling-demo \
#   --type=json -p='[{"op": "remove", "path": "/spec/schedulingGates"}]'

---
# Stage 4 Comparison: Pod without schedulingGates (Normal binding)
apiVersion: v1
kind: Pod
metadata:
  name: stage4-no-scheduling-gate
  namespace: scheduling-demo
  labels:
    test: stage4-binding
    component: no-gate
spec:
  # No schedulingGates -> Proceeds through entire Binding Cycle immediately
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"

---
# Stage 4 Test: Volume Binding with WaitForFirstConsumer
# volumeBindingMode affects Reserve/PreBind extension points:
# - Immediate: Bind volume before scheduling
# - WaitForFirstConsumer: Reserve/bind volume during Binding Cycle

# Create StorageClass with WaitForFirstConsumer
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: late-binding-sc
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer  # Volume binding happens in Stage 4
reclaimPolicy: Delete

---
# Create PersistentVolume on w1-k8s
apiVersion: v1
kind: PersistentVolume
metadata:
  name: demo-pv-w1
  labels:
    node: w1-k8s
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: late-binding-sc
  local:
    path: /mnt/disks/vol1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - w1-k8s

---
# Create PersistentVolumeClaim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
  namespace: scheduling-demo
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: late-binding-sc
  resources:
    requests:
      storage: 5Gi

---
# Stage 4 Test: Pod with Late-Bound Volume
apiVersion: v1
kind: Pod
metadata:
  name: stage4-volume-late-binding
  namespace: scheduling-demo
  labels:
    test: stage4-binding
    component: volume-binding
spec:
  nodeSelector:
    disktype: ssd
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: demo-pvc
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"
    volumeMounts:
    - name: storage
      mountPath: /data
# Expected Binding Cycle behavior:
# 1. Reserve: Volume reservation on selected node
# 2. Permit: Gate check (passes immediately)
# 3. PreBind: PVC binds to PV, volume mounts prepared
# 4. Bind: Pod bound to node (w1-k8s)
# 5. PostBind: Cleanup and notifications

---
# ============================================================
# Comprehensive Test: Pod with All Stages Combined
# ============================================================

apiVersion: v1
kind: Pod
metadata:
  name: comprehensive-scheduling-test
  namespace: scheduling-demo
  labels:
    test: comprehensive
    app: full-example
spec:
  # ====== Stage 2 Filter (Required) ======
  
  nodeSelector:
    disktype: ssd  # Filter: Only SSD nodes
  
  tolerations:
  - key: gpu
    operator: Equal
    value: nvidia
    effect: NoSchedule  # Filter: Allow gpu taint
  - key: maintenance
    operator: Equal
    value: "true"
    effect: PreferNoSchedule  # Stage 3: Maintenance node preference
  
  affinity:
    # Filter: Required NodeAffinity
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: zone
            operator: In
            values:
            - zone-a
            - zone-b
      
      # Stage 3: Preferred NodeAffinity
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - zone-a  # Prefer zone-a more
    
    # Stage 3: Preferred PodAffinity
    podAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 80
        podAffinityTerm:
          labelSelector:
            matchLabels:
              tier: cache
          topologyKey: kubernetes.io/hostname
    
    # Filter: Required PodAntiAffinity
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: full-example
        topologyKey: kubernetes.io/hostname  # Cannot be on same host
  
  # Filter: TopologySpread (Hard) - Evenly distribute across 3 zones
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: full-example
  
  # Filter: Resource Requests
  containers:
  - name: app
    image: quay.io/nginx/nginx-unprivileged:1.27.5-alpine-slim
    resources:
      requests:
        memory: "512Mi"  # Filter: Requires sufficient memory
        cpu: "500m"      # Stage 3: Also affects resource balancing
      limits:
        memory: "1Gi"
        cpu: "1000m"

---
# ============================================================
# Test Execution Guide
# ============================================================

# Node configuration:
# - Zone A (w1-k8s: SSD, w2-k8s: HDD)
# - Zone B (w3-k8s: SSD, w4-k8s: HDD)
# - Zone C (w5-k8s: SSD+GPU, w6-k8s: HDD+Maintenance)

# 1. Apply namespace and resource quota/limits
# kubectl apply -f this-file.yaml

# 2. Stage 0 Test (Verify LimitRange violation)
# kubectl get pod stage0-fail-limitrange -n stage0-demo
# Expected: Error (Failed to create due to LimitRange violation)

# 3. Stage 1 Test (Verify nodeName behavior)
# kubectl get pod stage1-nodename-direct -o wide
# Expected: Placed on w4-k8s, NOMINATED NODE empty

# 4. Stage 2 Test (Verify Filter stage)
# kubectl get pods -l test=stage2-filter -o wide
# Expected placement:
# - stage2-nodeselector (disktype=ssd): One of w1, w3, w5
# - stage2-required-affinity (zone a or b): One of w1, w2, w3, w4
# - stage2-toleration-required: Only w5 (gpu taint)
# - stage2-pod-antiaffinity: Each on different nodes

# 5. Stage 3 Test (Verify Score stage)
# kubectl get pods -l test=stage3-score -o wide
# Expected placement:
# - stage3-preferred-nodeaffinity: w1 or w2 preferred (zone-a, no taints)
# - stage3-preferred-podaffinity: Same node as cache-pod
# - stage3-prefer-no-schedule: w6 possible (with toleration)
# - stage3-no-prefer-toleration: w1, w3, w4 preferred (w6 has lower score)

# 6. Stage 4 Test (Verify Binding Cycle)
# kubectl get pods -l test=stage4-binding -o wide
# Expected behavior:
# - stage4-scheduling-gate-blocked: Status shows "SchedulingGated"
#   Node selected but not bound until gate is removed
# - stage4-no-scheduling-gate: Normal binding, Pod Running
# - stage4-volume-late-binding: Pod on w1-k8s (only node with PV and SSD)
#
# Check schedulingGates status:
# kubectl get pod stage4-scheduling-gate-blocked -o jsonpath='{.spec.schedulingGates}'
#
# Check PVC binding status:
# kubectl get pvc demo-pvc
# Expected: Bound after Pod is scheduled
#
# Remove schedulingGate to complete binding:
# kubectl patch pod stage4-scheduling-gate-blocked \
#   --type=json -p='[{"op": "remove", "path": "/spec/schedulingGates"}]'

# 7. Check detailed scheduling events
# kubectl describe pod <pod-name>

# 8. Check Pod distribution by zone
# kubectl get pods -o wide | grep -E "NAME|w1-k8s|w2-k8s|w3-k8s|w4-k8s|w5-k8s|w6-k8s"

# 9. Cleanup
# kubectl delete namespace stage0-demo
# kubectl delete pods -l test=stage1-nodename
# kubectl delete pods -l test=stage1-scheduler
# kubectl delete pods -l test=stage2-filter
# kubectl delete pods -l test=stage3-score
# kubectl delete pods -l test=stage4-binding
# kubectl delete pods -l test=comprehensive

# ============================================================
# DRA Testing Guide (Optional - Requires DRA Driver)
# ============================================================

# DRA is enabled by default in v1.34+ (core API stable; some features may require feature gates) but requires a DRA driver to function.
# Common DRA drivers:
# - NVIDIA GPU Operator (with DRA support)
# - Intel Device Plugins Operator
# - Custom DRA drivers

# Check if DRA is available:
# kubectl api-resources | grep resource.k8s.io

# Check if any ResourceSlices exist:
# kubectl get resourceslices

# If you have a DRA driver installed:
# 1. List available DeviceClasses:
#    kubectl get deviceclasses
# 
# 2. Create a test ResourceClaimTemplate (see DRA section above)
# 
# 3. Create a Pod using the ResourceClaimTemplate
# 
# 4. Verify scheduling with DRA:
#    kubectl describe pod <dra-pod-name> -n scheduling-demo
#    # Look for ResourceClaim allocation events
# 
# 5. Check ResourceClaim status:
#    kubectl get resourceclaims -n scheduling-demo -o yaml
#    # Check status.allocation for device assignment
# 
# 6. Verify the Pod landed on a node with the allocated device:
#    kubectl get pod <dra-pod-name> -n scheduling-demo -o wide
#
# DRA Scheduling Stages Summary:
# - Stage 0: ResourceClaim validates against ResourceQuota/LimitRange
# - Stage 2 (Filter): Scheduler filters nodes based on:
#   * ResourceSlice availability (devices exist on node)
#   * Device matches ResourceClaim requirements
#   * Node can access the devices
# - Stage 3 (Score): Scheduler scores nodes based on:
#   * Device availability and allocation status
#   * Resource balancing across devices
# - Stage 4 (Binding Cycle): ResourceClaim allocation is finalized
#   * Reserve: ResourceClaim reservation on selected node
#   * PreBind: ResourceClaim.status.allocation updated with device details
#   * Bind: Pod is bound to the selected node with allocated devices
