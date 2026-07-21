#!/usr/bin/env bash
# Clean up demo resources only (does not touch the 7 PoC implementations).
# To fully restore the PoC cluster, use test-cluster/reset.sh (snapshot restore).
set -euo pipefail
CTX="${KUBE_CONTEXT:-kubecon-demo}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl config use-context "$CTX" >/dev/null

# Demo object name(s). Delete by TYPE+NAME (not by manifest file) so a rename of the manifests
# never strands old objects. List any historical names here so cleanup stays idempotent.
APP_NAMES="${APP_NAMES:-jp-front jp-gateway echo}"
# The Gateway (and its NGF data-plane <name>-nginx) lives in the infra ns (nginx-gateway); the
# HTTPRoute/Ingress/backend live in the app ns (default). We delete the demo OBJECTS from both,
# but NEVER delete the nginx-gateway namespace itself (it holds the shared NGF controller).
APP_NS="${APP_NS:-default nginx-gateway}"
APP_KINDS="gateway.gateway.networking.k8s.io httproute.gateway.networking.k8s.io ingress deployment service"

# Delete a namespace; if it hangs in Terminating (finalizer="kubernetes", 0 resources), force-finalize.
# The ingress-nginx ns often gets stuck this way and delete blocks forever, so we add a fallback.
delete_ns() {
  local ns="$1"
  kubectl get ns "$ns" >/dev/null 2>&1 || return 0
  if ! kubectl delete ns "$ns" --timeout=30s 2>/dev/null; then
    echo "   ($ns stuck Terminating → force-finalize)"
    kubectl get ns "$ns" -o json \
      | python3 -c "import sys,json;d=json.load(sys.stdin);d['spec']['finalizers']=[];print(json.dumps(d))" \
      | kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f - >/dev/null 2>&1 || true
  fi
}

echo "==> remove demo objects (Gateway/HTTPRoute/Ingress/backend) from app + infra namespaces"
# By TYPE+NAME across both namespaces, not by manifest: a rename/ns-move never leaves objects behind.
# Deleting the Gateway lets NGF garbage-collect its <name>-nginx data plane; we also remove it directly.
for ns in $APP_NS; do
  for name in $APP_NAMES; do
    for kind in $APP_KINDS; do
      kubectl -n "$ns" delete "$kind" "$name" --ignore-not-found
      kubectl -n "$ns" delete "$kind" "${name}-nginx" --ignore-not-found   # NGF data-plane object
    done
  done
done

echo "==> remove ingress-nginx (demo-only LB controller)"
helm uninstall ingress-nginx -n ingress-nginx 2>/dev/null || true
delete_ns ingress-nginx

echo ""
echo "==> cleanup complete. Removed the demo resources (jp-front) + ingress-nginx."
echo "    KEPT ON PURPOSE (infrastructure, so the next rehearsal is fast):"
echo "      - nginx-gateway ns : the NGF controller (installed once by cluster/install-ngf.sh)"
echo "      - metallb-system   : MetalLB (LB IP pool .11-17)"
echo "      - CNI / kube-system: base cluster"
echo "    'kubectl get ns' still showing nginx-gateway/metallb-system is EXPECTED, not leftover."
echo ""
echo "    Next rehearsal : ./0.setup_before.sh   (NGF controller is already up → rebuilds in seconds)"
echo "    Full wipe       : ../cluster/reset.sh   (restore baseline snapshot — also drops NGF/MetalLB)"
