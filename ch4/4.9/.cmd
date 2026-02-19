
### Step 0. 앱 배포 (4.8과 동일한 deploy-*.yaml 사용)
kubectl apply -f deploy-nginx.yaml -f deploy-hn.yaml -f deploy-ip.yaml

### Step 1. ingress2gateway 도구 설치
bash ingress2gateway_installer.sh

### Step 2. 기존 ingress.yaml → gateway.yaml 변환
# 파일 기반 변환
ingress2gateway print --providers=ingress-nginx --input-file=ingress.yaml -A > gateway.yaml

# 클러스터에서 직접 변환 (대안)
# ingress2gateway print --providers=ingress-nginx --all-namespaces > gateway.yaml

### Step 3. NGINX Gateway Fabric 설치 (CRD + 배포 일괄)
bash nginx_gw_fabric_installer.sh

### Step 4. 변환된 gateway.yaml 적용
kubectl apply -f gateway.yaml
# gateway.gateway.networking.k8s.io/nginx created
# httproute.gateway.networking.k8s.io/nginx-ingress-all-hosts created

### Step 5. 리소스 상태 확인
kubectl get gateway
# NAME    CLASS   ADDRESS        PROGRAMMED   AGE
# nginx   nginx   192.168.1.11   True         32s

kubectl get httproute
# NAME                      HOSTNAMES   AGE
# nginx-ingress-all-hosts               55s

### Step 6. 접속 테스트
GATEWAY_IP=$(kubectl get gateway nginx -o jsonpath='{.status.addresses[0].value}')
echo ${GATEWAY_IP}
# 192.168.1.11

curl -s http://${GATEWAY_IP}/
curl -s http://${GATEWAY_IP}/hn
curl -s http://${GATEWAY_IP}/ip

### Cleanup (실습 정리)
kubectl delete -f gateway.yaml
kubectl delete -f deploy-nginx.yaml -f deploy-hn.yaml -f deploy-ip.yaml
bash nginx_gw_fabric_uninstaller.sh
