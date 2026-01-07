# Kubernetes 클러스터 수동 설치 가이드

> **참고**: 기본적으로는 상위 폴더(`../`)의 `vagrant up`을 사용하는 것을 권장합니다.
> 이 가이드는 `vagrant up` 시 provision 과정에서 에러가 발생하는 경우에 사용하는 대안입니다.

VM만 생성하고, 쿠버네티스 설정은 수동으로 진행하는 방법입니다.

## 사전 요구사항

다음 소프트웨어가 설치되어 있어야 합니다:

- **VirtualBox**: `virtualbox-v7.0.18` 폴더 참고
- **Vagrant**: `vagrant-v2.4.1` 폴더 참고
- **터미널 프로그램**: Tabby(`tabby-v1.0.207` 폴더) 또는 다른 터미널 프로그램 사용 가능

## 폴더 구조

```
manual-setup/
├── README.md              # 이 가이드
├── Vagrantfile            # provision 없는 간소화 버전
├── k8s_env_build.sh       # 환경 구성 스크립트
├── k8s_pkg_cfg.sh         # 패키지 설치 스크립트
├── controlplane_node.sh   # Control Plane 초기화 스크립트
├── worker_nodes.sh        # Worker 조인 스크립트
└── extra_k8s_pkgs.sh      # 추가 패키지 설치 (helm, metallb, ingress 등)
```

## 클러스터 구성

| 노드 | VM 이름 | 호스트명 | IP | SSH 포트 | CPU | Memory |
|------|---------|----------|-----|----------|-----|--------|
| Control Plane | cp-k8s-1.30.1 | cp-k8s | 192.168.1.10 | 60010 | 2 | 2048MB |
| Worker 1 | w1-k8s-1.30.1 | w1-k8s | 192.168.1.101 | 60101 | 1 | 1536MB |
| Worker 2 | w2-k8s-1.30.1 | w2-k8s | 192.168.1.102 | 60102 | 1 | 1536MB |
| Worker 3 | w3-k8s-1.30.1 | w3-k8s | 192.168.1.103 | 60103 | 1 | 1536MB |

**VirtualBox 그룹**: `/k8s-adv-U1.30.1-ctrd-1.6(manual)`

---

## 1단계: VM 생성

이 폴더에서 실행합니다.

```cmd
cd manual-setup

:: VM을 하나씩 순차적으로 올립니다 (에러 발생 시 개별 대응 가능)
vagrant up cp-k8s-1.30.1
vagrant up w1-k8s-1.30.1
vagrant up w2-k8s-1.30.1
vagrant up w3-k8s-1.30.1

:: 또는 한 번에
vagrant up
```

---

## 2단계: 스크립트 파일 업로드

각 VM에 스크립트 파일을 업로드합니다.

```cmd
:: Control Plane
vagrant upload k8s_env_build.sh /home/vagrant/k8s_env_build.sh cp-k8s-1.30.1
vagrant upload k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh cp-k8s-1.30.1
vagrant upload controlplane_node.sh /home/vagrant/controlplane_node.sh cp-k8s-1.30.1
vagrant upload extra_k8s_pkgs.sh /home/vagrant/extra_k8s_pkgs.sh cp-k8s-1.30.1

:: Worker 1
vagrant upload k8s_env_build.sh /home/vagrant/k8s_env_build.sh w1-k8s-1.30.1
vagrant upload k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh w1-k8s-1.30.1
vagrant upload worker_nodes.sh /home/vagrant/worker_nodes.sh w1-k8s-1.30.1

:: Worker 2
vagrant upload k8s_env_build.sh /home/vagrant/k8s_env_build.sh w2-k8s-1.30.1
vagrant upload k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh w2-k8s-1.30.1
vagrant upload worker_nodes.sh /home/vagrant/worker_nodes.sh w2-k8s-1.30.1

:: Worker 3
vagrant upload k8s_env_build.sh /home/vagrant/k8s_env_build.sh w3-k8s-1.30.1
vagrant upload k8s_pkg_cfg.sh /home/vagrant/k8s_pkg_cfg.sh w3-k8s-1.30.1
vagrant upload worker_nodes.sh /home/vagrant/worker_nodes.sh w3-k8s-1.30.1
```

---

## 3단계: Control Plane 노드 설정

```cmd
vagrant ssh cp-k8s-1.30.1
```

VM 내부에서:
```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.30
sudo ./k8s_pkg_cfg.sh 1.30.1-1.1 1.6.31-1 CP
sudo ./controlplane_node.sh
```

vagrant 유저용 kubeconfig 설정:
```bash
mkdir -p ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

추가 패키지 설치 (helm, metallb, ingress, nfs 등):
```bash
sudo ./extra_k8s_pkgs.sh
```

설치 확인:
```bash
kubectl get nodes
kubectl get pods -A
```

**완료 후 exit로 SSH 종료**

---

## 4단계: Worker 노드 설정

각 Worker 노드에서 동일하게 진행합니다.

### Worker 1

```cmd
vagrant ssh w1-k8s-1.30.1
```

VM 내부에서:
```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.30
sudo ./k8s_pkg_cfg.sh 1.30.1-1.1 1.6.31-1 W
sudo ./worker_nodes.sh
```

**exit로 종료 후 w2, w3도 동일하게 진행**

### Worker 2

```cmd
vagrant ssh w2-k8s-1.30.1
```

```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.30
sudo ./k8s_pkg_cfg.sh 1.30.1-1.1 1.6.31-1 W
sudo ./worker_nodes.sh
```

### Worker 3

```cmd
vagrant ssh w3-k8s-1.30.1
```

```bash
chmod +x *.sh
sudo ./k8s_env_build.sh 3 1.30
sudo ./k8s_pkg_cfg.sh 1.30.1-1.1 1.6.31-1 W
sudo ./worker_nodes.sh
```

---

## 5단계: 클러스터 확인

```cmd
vagrant ssh cp-k8s-1.30.1
```

```bash
kubectl get nodes
```

예상 출력:
```
NAME     STATUS   ROLES           AGE   VERSION
cp-k8s   Ready    control-plane   10m   v1.30.1
w1-k8s   Ready    <none>          5m    v1.30.1
w2-k8s   Ready    <none>          3m    v1.30.1
w3-k8s   Ready    <none>          1m    v1.30.1
```

시스템 파드 확인:
```bash
kubectl get pods -A
```

---

## 문제 해결

### VM 재시작이 필요한 경우

```cmd
vagrant reload cp-k8s-1.30.1
vagrant reload w1-k8s-1.30.1 w2-k8s-1.30.1 w3-k8s-1.30.1
```

### 특정 VM만 다시 생성

```cmd
vagrant destroy w1-k8s-1.30.1 -f
vagrant up w1-k8s-1.30.1
:: 이후 스크립트 업로드 및 설정 다시 진행
```

### SSH 접속이 안 되는 경우

```cmd
:: 포트 포워딩 확인
vagrant port cp-k8s-1.30.1

:: 직접 SSH 접속
ssh -p 60010 vagrant@127.0.0.1
:: 비밀번호: vagrant
```

### 스크립트 실행 중 에러 발생 시

각 스크립트는 독립적으로 실행 가능하므로, 에러 발생 시 해당 명령만 수동으로 실행할 수 있습니다.

**k8s_env_build.sh 주요 작업:**
- swap 비활성화
- kubernetes/docker 저장소 추가
- /etc/hosts 설정

**k8s_pkg_cfg.sh 주요 작업:**
- NFS 패키지 설치
- kubelet, kubectl, kubeadm, containerd 설치
- containerd 설정

**controlplane_node.sh 주요 작업:**
- kubeadm init (토큰: 123456.1234567890123456)
- kubectl 설정
- Calico CNI 설치
- 인증서 10년 연장

**worker_nodes.sh 주요 작업:**
- kubeadm join

**extra_k8s_pkgs.sh 주요 작업:**
- Helm 설치
- MetalLB 설치 및 설정
- Nginx Ingress Controller 설치
- Metrics Server 설치
- NFS Provisioner 설치

---

## 전체 삭제

```cmd
vagrant destroy -f
```
