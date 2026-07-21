
### Step 0. 앱 배포 (4.8과 동일한 deploy-*.yaml 사용)
kubectl apply -f deploy-nginx.yaml -f deploy-hn.yaml -f deploy-ip.yaml

### Step 1. ingress2gateway 도구 설치
bash ingress2gateway_installer.sh

### Step 2. 기존 ingress.yaml → 변환 결과 확인
# 파일 기반 변환. 저장소의 gateway.yaml을 덮어쓰지 않도록 다른 이름으로 받는다.
ingress2gateway print --providers=ingress-nginx --input-file=ingress.yaml -A > gateway-converted.yaml

# 클러스터에서 직접 변환 (대안)
# ingress2gateway print --providers=ingress-nginx --all-namespaces > gateway-converted.yaml

# 참고: URL 정규화 관련 WARN이 뜨는데 변환할 때 항상 나오는 안내다.
# Gateway API 표준에 해당 설정 필드가 없다는 뜻이고, 이 실습에는 영향이 없다.
# 이 메시지는 stderr로 나가므로 저장된 파일에는 섞이지 않는다.

### Step 2.5. 변환 결과 이름 정리
# ingress2gateway는 Gateway 이름을 GatewayClass와 같은 nginx로 생성한다.
# get 출력에서 NAME/CLASS가 둘 다 nginx로 나와 헷갈리므로, 역할이 드러나는
# external로 바꾼다. HTTPRoute도 nginx-multipath로 정리한다. (책 ch3/3.3.3과 동일한 관례)
# 저장소의 gateway.yaml에는 이렇게 정리한 결과가 들어 있다. 이름만 비교해 본다.
grep -E "^kind:|^  name:|^  - name:" gateway.yaml gateway-converted.yaml
# gateway.yaml:kind: Gateway
# gateway.yaml:  name: external
# gateway.yaml:  - name: http
# gateway.yaml:kind: HTTPRoute
# gateway.yaml:  name: nginx-multipath
# gateway.yaml:  - name: external
# gateway-converted.yaml:kind: Gateway
# gateway-converted.yaml:  name: nginx
# gateway-converted.yaml:  - name: http
# gateway-converted.yaml:kind: HTTPRoute
# gateway-converted.yaml:  name: nginx-ingress-all-hosts
# gateway-converted.yaml:  - name: nginx

# 전체 차이를 보려면 (필드 순서까지 달라서 출력이 길다)
# diff gateway-converted.yaml gateway.yaml

### Step 3. NGINX Gateway Fabric 설치 (CRD + 배포 일괄)
bash nginx_gw_fabric_installer.sh

### Step 4. 변환된 gateway.yaml 적용
kubectl apply -f gateway.yaml
# gateway.gateway.networking.k8s.io/external created
# httproute.gateway.networking.k8s.io/nginx-multipath created

### Step 5. 리소스 상태 확인
kubectl get gateway
# NAME       CLASS   ADDRESS        PROGRAMMED   AGE
# external   nginx   192.168.1.11   True         32s

kubectl get httproute
# NAME              HOSTNAMES   AGE
# nginx-multipath               55s

### Step 6. 접속 테스트
GATEWAY_IP=$(kubectl get gateway external -o jsonpath='{.status.addresses[0].value}')
echo ${GATEWAY_IP}
# 192.168.1.11

curl -s http://${GATEWAY_IP}/
curl -s http://${GATEWAY_IP}/hn
curl -s http://${GATEWAY_IP}/ip

### Cleanup (실습 정리)
kubectl delete -f gateway.yaml
kubectl delete -f deploy-nginx.yaml -f deploy-hn.yaml -f deploy-ip.yaml
bash nginx_gw_fabric_uninstaller.sh
rm -f gateway-converted.yaml
