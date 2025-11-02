# KubeCon NA 2025 Demo

This directory contains demonstration materials for KubeCon North America 2025.

## Directory Structure

```
.
├── k8s-cluster-builder/   # Kubernetes cluster setup and configuration
└── k8s-scheduler/         # Kubernetes scheduling demonstration and examples
```

## Contents

### k8s-cluster-builder
Tools and scripts for building and configuring a Kubernetes test cluster with:
- 6-node worker configuration
- Custom node labels (zones, disk types)
- Taints for specialized workloads

### k8s-scheduler
Comprehensive Kubernetes scheduling demonstration covering all 5 stages:
- **Stage 0**: Admission Control (ResourceQuota, LimitRange, DRA validation)
- **Stage 1**: nodeName (Scheduler Bypass)
- **Stage 2**: Scheduler Filter (Hard Constraints)
- **Stage 3**: Scheduler Score (Soft Constraints)
- **Stage 4**: Binding Cycle (Pod-Node Binding)

## Prerequisites

- Kubernetes cluster v1.31+ (v1.34 compatible)
- kubectl CLI tool
- 6 worker nodes with appropriate labels and taints

## Quick Start

1. **Set up the cluster**:
   ```bash
   cd k8s-cluster-builder
   # Follow instructions in the directory README
   ```

2. **Run scheduling demos**:
   ```bash
   cd k8s-scheduler
   # Follow instructions in the directory README
   ```

## Documentation

Each subdirectory contains its own README.md with detailed instructions and examples.

## License

This demo is provided as-is for educational purposes at KubeCon NA 2025.
