#!/usr/bin/env bash

# NGINX Gateway Fabric Uninstaller
# 설치의 역순으로 삭제합니다.

set -e

GATEWAY_API_VERSION="v1.2.0"
NGF_VERSION="v2.2.1"

echo "=== Step 1/3: NGINX Gateway Fabric 배포 삭제 ==="
kubectl delete -f nginx_gw_fabric_deploy.yaml --ignore-not-found
echo ""

echo "=== Step 2/3: NGINX Gateway Fabric CRD 삭제 ==="
kubectl delete -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/${NGF_VERSION}/deploy/crds.yaml --ignore-not-found
echo ""

echo "=== Step 3/3: Gateway API CRD 삭제 ==="
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml --ignore-not-found
echo ""

echo "=== 삭제 완료 ==="
