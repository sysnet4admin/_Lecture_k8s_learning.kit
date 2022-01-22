### istio를 통한 MSA 실습 랩 (v1.23.2)

실습을 하기 위해서 필요한 패키지를 종합해 놓음. 
따라서 수시로 업데이트 될 수 있습니다.  

이름              | 버전     |   빈칸 
----            | ----    | ---- 
kubernetes      | v1.23.2 | 
istioctl        | v1.12.2 |
MetalLB         | v0.10.2 | 
nfs-provisioner | 4.0.2   |
Metrics Server  | 0.5.0   |
Kustomize       | 4.2.0   |
Helm            | 3.6.3   |

### ⚠ 필수 실행 
istio의 구성을 위해서 모든 클러스터의 구성이 완료된 이후에 다음의 명령을 수행해야 합니다. 
```bash 
istioctl install --set profile=demo -y
```
다음의 명령어로 설치 상태를 확인할 수 있습니다. 
```bash 
istioctl x precheck
```

#### 특이점 
helm 자동 완성 기능을 사용하길 원한다면, 다음의 명령을 수행해야 합니다.  
```bash
sh /tmp/helm_completion.sh
```
