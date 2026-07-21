#!/usr/bin/env bash
# Build the demo BEFORE state: ingress-nginx + jp-front app + a simple Ingress (same IP = .12),
# PLUS the NGF Gateway pre-deployed and warmed up (its LB Service stays <pending> while
# ingress-nginx holds .12). This pre-warm is what makes the live handover near-instant:
# the NGF data-plane pod is already Ready, so retiring ingress-nginx hands .12 over in ~1.6s
# instead of the ~15s it takes to provision a fresh data-plane pod mid-demo.
# Run once before the demo. When done, clean up with 9.cleanup_demo.sh.
set -euo pipefail

CTX="${KUBE_CONTEXT:-kubecon-demo}"
DEMO_IP="${DEMO_IP:-192.168.1.12}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> context: $CTX / demo IP: $DEMO_IP"
kubectl config use-context "$CTX" >/dev/null

echo "==> [1/5] install ingress-nginx (LB IP = $DEMO_IP)"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null 2>&1 || true
helm repo update ingress-nginx >/dev/null
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."metallb\.io/loadBalancerIPs"="$DEMO_IP" \
  --set controller.watchIngressWithoutClass=false \
  --wait --timeout 5m

echo "==> [2/5] deploy backend + Ingress"
kubectl apply -f "$HERE/manifests/00-backend.yaml"
kubectl apply -f "$HERE/manifests/01-ingress.yaml"

# MetalLB is also CLUSTER infra — applied by cluster/up.sh AFTER `vagrant up` (not by vagrant up
# itself). If you ran bare `vagrant up`, MetalLB is missing and every LoadBalancer Service sits
# <pending> forever, so ingress-nginx never gets $DEMO_IP. We don't print-and-pass on an empty IP
# anymore (that silently let the demo start half-ready); we WAIT for the IP and self-heal if absent.
echo "==> [3/5] wait for the LB IP $DEMO_IP (self-heal MetalLB if missing)"
_lb_ip() { kubectl -n ingress-nginx get svc ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true; }
_wait_lb_ip() { local i ip; for i in $(seq 1 10); do ip="$(_lb_ip)"; \
  [ -n "$ip" ] && { echo "    LB IP = $ip"; return 0; }; sleep 3; done; return 1; }
if ! _wait_lb_ip; then
  echo "    no LB IP after ~30s → ensuring MetalLB (cluster/metallb.sh; idempotent)"
  echo "    (this happens when only 'vagrant up' was run instead of cluster/up.sh)"
  "$HERE/cluster/metallb.sh"
  _wait_lb_ip || { echo "✗ still no LB IP after installing MetalLB. Check:" >&2
    echo "    kubectl -n metallb-system get pods,ipaddresspool,l2advertisement" >&2; exit 1; }
fi

# NGF + Gateway API CRDs are CLUSTER infra (installed once by cluster/install-ngf.sh, then captured
# in the baseline snapshot and KEPT by 9.cleanup so rehearsals stay fast) — not part of the
# per-rehearsal demo state. On a snapshot-backed laptop reset.sh restores them, so this is a no-op.
# But on a FRESH cluster (new laptop, ran only `vagrant up`) they are missing and [5/5] would die
# with a cryptic "no matches for kind Gateway". Self-heal: install once if absent, skip if present.
echo "==> [4/5] ensure Gateway API CRDs + NGF (infra; auto-install only if missing)"
if kubectl get gatewayclass nginx >/dev/null 2>&1; then
  echo "    GatewayClass 'nginx' present → skip (already installed)"
else
  echo "    GatewayClass 'nginx' not found → running cluster/install-ngf.sh (one-time infra setup)"
  KUBE_CONTEXT="$CTX" "$HERE/cluster/install-ngf.sh"
fi

echo "==> [5/5] pre-deploy + warm up the NGF Gateway (Service stays <pending> while ingress holds $DEMO_IP)"
kubectl apply -f "$HERE/manifests/03-gateway-ngf.yaml"
echo "    waiting for NGF to create the data-plane Deployment..."
for i in $(seq 1 30); do
  kubectl -n nginx-gateway get deploy jp-gateway-nginx >/dev/null 2>&1 && break
  sleep 2
done
echo "    waiting for the data-plane pod to be Ready (this is the warm-up that the demo skips)..."
kubectl -n nginx-gateway rollout status deploy/jp-gateway-nginx --timeout=120s || true
echo ""
echo "BEFORE ready. Sanity:"
echo "  curl --resolve demo.kubecon.jp:80:$DEMO_IP http://demo.kubecon.jp/   # → 'hello from KubeCon Japan 2026'"
echo "  kubectl get svc -n nginx-gateway -l app.kubernetes.io/managed-by=ngf-nginx   # → EXTERNAL-IP <pending> (waiting for .12)"
echo "Now run watch_curl.sh in the left pane and 1.migrate_to_gateway.sh in the right."
