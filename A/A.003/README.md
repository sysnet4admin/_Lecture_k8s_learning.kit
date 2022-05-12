### 실습 랩 All-in-one 
실습을 하기 위해서 필요한 패키지를 종합해 놓음. 
따라서 수시로 업데이트 될 수 있습니다.  

#### C: CentOS (v1.24.0)
이름            | 버전     |   빈칸 
----            | ----    | ---- 
kubernetes      | v1.24.0 | 
ContainerD      | 1.6.4  |
MetalLB         | v0.10.2 | 
nfs-provisioner | 4.0.2   |
Metrics Server  | 0.5.0   |
Kustomize       | 4.2.0   |
Helm            | 3.6.3   |

#### U: Ubuntu (v1.24.1) <<<< It will work properly the end of May.
이름            | 버전     |   빈칸 
----            | ----    | ---- 
kubernetes      | v1.24.1 |
ContainerD      | 1.6.4  |
MetalLB         | v0.10.2 | 
nfs-provisioner | 4.0.2   |
Metrics Server  | 0.5.0   |
Kustomize       | 4.2.0   |
Helm            | 3.6.3   |


#### 특이점 
helm 자동 완성 기능을 사용하길 원한다면, 다음의 명령을 수행해야 합니다.  
```bash
sh /tmp/helm_completion.sh
```
