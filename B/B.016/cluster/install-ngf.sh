#!/usr/bin/env bash
# Install only the Gateway API CRDs + NGINX Gateway Fabric on the demo cluster.
# (The PoC installs all 7 implementations, but the demo only needs NGF.)
# Run once after up.sh brings the base cluster to Ready.
set -euo pipefail

CTX="${KUBE_CONTEXT:-kubecon-demo}"
GWAPI_VERSION="${GWAPI_VERSION:-v1.4.1}"        # NGF 2.4.2 = Gateway API 1.4.1
NGF_VERSION="${NGF_VERSION:-2.4.2}"            # avoid the latest 2.6.x (targets v1.5)
kubectl config use-context "$CTX" >/dev/null

echo "==> [1/2] Gateway API ${GWAPI_VERSION} standard channel CRDs"
# server-side: the HTTPRoute CRD exceeds the 256KB client-side apply limit
kubectl apply --server-side --force-conflicts -f \
  "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GWAPI_VERSION}/standard-install.yaml"

echo "==> [2/2] NGINX Gateway Fabric ${NGF_VERSION} (ns nginx-gateway)"
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --version "${NGF_VERSION}" \
  --namespace nginx-gateway --create-namespace --wait

echo "==> check GatewayClass 'nginx'"
kubectl get gatewayclass nginx 2>/dev/null || echo "(waiting for auto-creation — re-check shortly)"
echo "Done. Next: ../scripts/0.setup_before.sh (ingress-nginx + jp-front + Ingress)"
