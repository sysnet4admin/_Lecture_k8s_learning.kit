# Kubernetes Cluster Builder

This directory contains scripts and configuration for building a Kubernetes test cluster using Vagrant.

## Overview

Automated setup for a multi-node Kubernetes cluster suitable for scheduling demonstrations:
- 1 control plane node
- 6 worker nodes with custom labels and taints

## Prerequisites

- [Vagrant](https://www.vagrantup.com/) 2.3+
- [VirtualBox](https://www.virtualbox.org/) 7.0+ (or another Vagrant provider)
- 4+ physical CPU cores (CPU overcommit supported)
- 8GB RAM minimum (10GB recommended for host OS overhead)
- ~60GB disk space

## Node Configuration

The cluster is configured with the following topology:

| Node | Role | Zone | Disk Type | Taints |
|------|------|------|-----------|--------|
| cp-k8s | Control Plane | - | - | control-plane |
| w1-k8s | Worker | zone-a | ssd | - |
| w2-k8s | Worker | zone-a | hdd | - |
| w3-k8s | Worker | zone-b | ssd | - |
| w4-k8s | Worker | zone-b | hdd | - |
| w5-k8s | Worker | zone-c | ssd | gpu:nvidia=NoSchedule |
| w6-k8s | Worker | zone-c | hdd | maintenance:true=PreferNoSchedule |

## Quick Start

### 1. Build the Cluster

```bash
vagrant up
```

This will:
- Provision 7 VMs (1 control plane + 6 workers)
- Install Kubernetes components
- Configure the cluster with kubeadm
- Apply node labels and taints

### 2. Access the Cluster

```bash
# SSH into control plane
vagrant ssh cp-k8s

# Check cluster status
kubectl get nodes -o wide
```

### 3. Configure kubectl Locally (Optional)

```bash
# Copy kubeconfig from control plane
vagrant ssh cp-k8s -c "cat ~/.kube/config" > ~/.kube/kubecon-demo-config

# Set KUBECONFIG environment variable
export KUBECONFIG=~/.kube/kubecon-demo-config

# Verify connectivity
kubectl get nodes
```

## Scripts

- **Vagrantfile**: VM and cluster configuration
- **k8s_env_build.sh**: System preparation and kernel module setup
- **k8s_pkg_cfg.sh**: Kubernetes package installation
- **controlplane_node.sh**: Control plane initialization
- **worker_nodes.sh**: Worker node join script
- **extra_k8s_pkgs.sh**: Additional Kubernetes tools and configurations (Helm, NFS provisioner, Cilium networking, node labels/taints)

## Cluster Operations

### Check Node Labels

```bash
kubectl get nodes --show-labels
```

### Check Node Taints

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

### Add/Modify Labels

```bash
# Add label
kubectl label nodes w1-k8s disktype=ssd

# Remove label
kubectl label nodes w1-k8s disktype-
```

### Add/Modify Taints

```bash
# Add taint
kubectl taint nodes w5-k8s gpu=nvidia:NoSchedule

# Remove taint
kubectl taint nodes w5-k8s gpu:NoSchedule-
```

## Troubleshooting

### Cluster not starting

```bash
# Restart cluster
vagrant reload

# Destroy and rebuild
vagrant destroy -f
vagrant up
```

### Check VM logs

```bash
vagrant ssh <node-name>
sudo journalctl -u kubelet -f
```

### Reset specific node

```bash
vagrant ssh <node-name>
sudo kubeadm reset -f
```

## Cleanup

```bash
# Stop VMs
vagrant halt

# Destroy all VMs
vagrant destroy -f
```

## Resource Requirements

- **Control Plane**: 2 vCPU, 2GB RAM
- **Each Worker**: 1 vCPU, 1GB RAM
- **Total Allocated**: 8 vCPU (overcommitted), 8GB RAM
- **Recommended Host**: 4+ physical CPU cores, 10GB RAM

## Network Configuration

- **Pod Network**: 172.16.0.0/16 (Cilium v1.17.4)
- **Service Network**: 10.96.0.0/12
- **VM Network**: 192.168.1.0/24 (Host-only network)

## Notes

- This cluster is designed for demonstration and testing purposes only
- Not suitable for production use
- Default credentials are used (insecure)
- All nodes run Ubuntu 22.04 LTS

## Support

For issues or questions related to the cluster setup, please refer to the main DEMO directory README.
