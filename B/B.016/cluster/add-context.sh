#!/usr/bin/env bash
# Add (or refresh) the demo cluster as a context in your kubeconfig — WITHOUT overwriting
# any other entry. Uses `kubectl config set-cluster/set-credentials/set-context`, each of
# which touches ONLY its named entry (never a full-file rewrite / flatten). Backs up the
# kubeconfig first. Idempotent: re-run after a cluster rebuild to refresh the (new) certs.
#
# Usage:
#   ./add-context.sh                 # add/refresh context 'kubecon-demo' in ~/.kube/config
#   KUBECONFIG=/path ./add-context.sh
set -euo pipefail
source "$(dirname "$0")/config.sh"

KCFG="${KUBECONFIG:-$HOME/.kube/config}"
CTX="$KUBE_CONTEXT"          # kubecon-demo (from config.sh)
CLUSTER="$CTX"
USER_NAME="${CTX}-admin"

# 1) backup (always, before any mutation)
if [ -f "$KCFG" ]; then
  cp "$KCFG" "${KCFG}.bak-$(date +%Y%m%d-%H%M%S)"
  echo "==> backed up $KCFG"
fi

# 2) pull a fresh admin.conf from the CP VM (it has cluster 'kubernetes' / user 'kubernetes-admin')
TMP="$(mktemp)"; trap 'rm -f "$TMP" "$CA" "$CRT" "$KEY"' EXIT
( cd "$CLUSTER_DIR" && vagrant ssh "$CP_VM" -c "sudo cat /etc/kubernetes/admin.conf" ) > "$TMP" 2>/dev/null
[ -s "$TMP" ] || { echo "ERROR: could not read admin.conf from $CP_VM (is the cluster up?)" >&2; exit 1; }

SERVER="$(KUBECONFIG="$TMP" kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}')"

# 3) decode the embedded cert material to PEM temp files (python3 = portable base64 decode)
b64d() { python3 -c "import sys,base64;sys.stdout.buffer.write(base64.b64decode(sys.stdin.read()))"; }
CA="$(mktemp)"; CRT="$(mktemp)"; KEY="$(mktemp)"
KUBECONFIG="$TMP" kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | b64d > "$CA"
KUBECONFIG="$TMP" kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}'        | b64d > "$CRT"
KUBECONFIG="$TMP" kubectl config view --raw -o jsonpath='{.users[0].user.client-key-data}'                | b64d > "$KEY"

# 4) additively write ONLY the kubecon-demo cluster/user/context (other entries untouched)
kubectl --kubeconfig "$KCFG" config set-cluster "$CLUSTER" \
  --server="$SERVER" --certificate-authority="$CA" --embed-certs=true
kubectl --kubeconfig "$KCFG" config set-credentials "$USER_NAME" \
  --client-certificate="$CRT" --client-key="$KEY" --embed-certs=true
kubectl --kubeconfig "$KCFG" config set-context "$CTX" \
  --cluster="$CLUSTER" --user="$USER_NAME"

echo "==> context '$CTX' added/refreshed (server $SERVER)"
echo "==> verify:"
kubectl --kubeconfig "$KCFG" --context "$CTX" get nodes
