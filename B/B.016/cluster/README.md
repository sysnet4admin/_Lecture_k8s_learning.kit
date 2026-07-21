# Demo Cluster (reduced clone of the PoC test-cluster)

> For the KubeCon Japan 2026 live demo only. Cloned from the PoC `test-cluster/` and reduced to
> **workers 3→1, 2 nodes total**, kept separate from the PoC (IPs in the `.160` range, VM group
> `/KubeConJapan2026-U1.36.1-ctrd-2.2(github_SysNet4Admin)`, context `kubecon-demo`).

## What gets created

| Item | Value |
|---|---|
| Nodes | cp-k8s(`.160`) + w1-k8s(`.161`) = **2 nodes** (2 vCPU / 4 GB each) |
| K8s | v1.36.1, Ubuntu 24.04, containerd 2.2.3 |
| CNI | Calico v3.31.2 (standard kube-proxy) |
| LB | MetalLB L2, pool `192.168.1.11-17` (demo IP = `.12`) |
| GatewayClass | `nginx` (NGINX Gateway Fabric 2.4.2 = Gateway API 1.4.1) |
| Host footprint | 4 vCPU / 8 GB (half of the 4-node PoC) |

> Node IPs differ from the PoC (`.150` vs `.160` range) so there is no IP clash, but the
> **MetalLB pool (.11-17) is the same, so do not run both clusters at the same time** (L2 IP clash).

## Usage

```bash
cd cluster
./up.sh                  # provision 2 nodes + MetalLB (~15-20 min on first boot)
# import the kubeconfig as context 'kubecon-demo'
./install-ngf.sh         # install Gateway API CRDs + NGF only
                         # (optional now: ../scripts/0.setup_before.sh self-heals and runs this
                         #  automatically if the GatewayClass is missing — handy on a fresh laptop)
./snapshot.sh            # baseline snapshot (once, before rehearsals)
./status.sh              # check status
./reset.sh               # restore snapshot (for repeated rehearsals, ~30-60s)
./down.sh                # destroy the VMs

# then build the demo BEFORE state → ../scripts/0.setup_before.sh
```

## Differences from the original

| | PoC test-cluster | Demo cluster |
|---|---|---|
| Workers | 3 (4 nodes total) | **1 (2 nodes total)** |
| CNI | Cilium (eBPF) | **Calico v3.31.2** (standard kube-proxy) |
| Implementations | all 7 | **NGF only** (`install-ngf.sh`) |
| Node IPs | `.150` range | `.160` range |
| VM group | `/gateway-PoC` | `/KubeConJapan2026-U1.36.1-ctrd-2.2(github_SysNet4Admin)` |
| context | `gateway-PoC` | `kubecon-demo` |
| SSH ports | 60160 range | 60160 range |

Original provisioning: the gateway-PoC `test-cluster/` (7-implementation comparison lab).
