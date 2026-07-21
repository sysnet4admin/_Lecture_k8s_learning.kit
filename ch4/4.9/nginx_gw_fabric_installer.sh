#!/usr/bin/env bash

# NGINX Gateway Fabric Installer for Kubernetes Gateway API
# - Gateway API CRDs (standard channel v1.5.1)
# - NGINX Gateway Fabric CRDs (v2.6.7)
# - NGINX Gateway Fabric Deployment (v2.6.7)
#
# NGF 2.6.x는 Gateway API v1.5.x를 권장한다(호환 범위 v1.2.1 ~ v1.5.x).
# v1.6.x는 아직 호환 목록에 없으므로 올리지 않는다.

set -e

GATEWAY_API_VERSION="v1.5.1"
NGF_VERSION="v2.6.7"

echo "=== Step 1/3: Gateway API CRD 설치 (${GATEWAY_API_VERSION}) ==="
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml
echo ""

echo "=== Step 2/3: NGINX Gateway Fabric CRD 설치 (${NGF_VERSION}) ==="
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/${NGF_VERSION}/deploy/crds.yaml
echo ""

echo "=== Step 3/3: NGINX Gateway Fabric 배포 (${NGF_VERSION}) ==="
kubectl apply -f nginx_gw_fabric_deploy.yaml
echo ""

echo "=== 설치 완료. 리소스 확인 ==="
echo ""
echo "--- GatewayClass ---"
kubectl get gatewayclasses
echo ""
echo "--- nginx-gateway 네임스페이스 ---"
kubectl get all -n nginx-gateway
echo ""
echo "NGINX Gateway Fabric 설치가 완료되었습니다."
echo "다음 단계: kubectl apply -f gateway.yaml"
