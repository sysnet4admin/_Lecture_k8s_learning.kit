### 실습 랩 All-in-one (v1.35)

이름            | 버전     | 검증
----            | ----     | ----
kubernetes      | 1.35.0   | ✅
ContainerD      | v2.2.1   | ✅
Calico CNI      | v3.31.2  | ✅
MetalLB         | v0.15.3  | ✅
nginx-gateway   | v2.3.0   | ✅
csi-driver-nfs  | v4.12.1  | ✅
Metrics Server  | v0.8.0   | ✅
Helm            | v4.0.4   | ✅

### 클러스터 구성

| 노드 | IP | 역할 | 리소스 |
|------|----|------|--------|
| cp-k8s | 192.168.1.10 | control-plane | 2 CPU, 4GB RAM |
| w1-k8s | 192.168.1.101 | worker | 1 CPU, 2GB RAM |
| w2-k8s | 192.168.1.102 | worker | 1 CPU, 2GB RAM |
| w3-k8s | 192.168.1.103 | worker | 1 CPU, 2GB RAM |

### 주요 기능

- **NGINX Gateway Fabric**: Gateway API 기반 인그레스 컨트롤러 (LoadBalancer IP 자동 할당)
- **MetalLB**: L2 모드로 LoadBalancer 서비스에 IP 할당 (192.168.1.11-99)
- **CSI Driver NFS**: 동적 PV 프로비저닝 (default StorageClass: managed-nfs-storage)
- **Metrics Server**: kubectl top 명령어 지원

