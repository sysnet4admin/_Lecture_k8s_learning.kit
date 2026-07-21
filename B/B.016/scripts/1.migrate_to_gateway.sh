#!/usr/bin/env bash
# Live demo RUNNER — not just a cheat sheet. Each step shows the command, waits for you to press
# Enter, then ACTUALLY RUNS it, so you control the pace while the audience sees real output.
# watch_curl.sh runs in the LEFT pane (continuous curl); run this in the RIGHT pane.
#
# set -e is intentionally OFF: a hiccup in one step must not abort the live demo.
set -uo pipefail
CTX="${KUBE_CONTEXT:-kubecon-demo}"
DEMO_IP="${DEMO_IP:-192.168.1.12}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Pin to the demo cluster so the active context (which might be gke etc.) is never touched.
kubectl config use-context "$CTX" >/dev/null 2>&1 || true

# Quick pre-check (just so we don't start the demo on a half-ready cluster). Two things matter:
# ingress-nginx must hold the IP (the 'working' source), and the NGF Gateway must be warm.
_ip=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
_prog=$(kubectl get gateway jp-gateway -n nginx-gateway -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}' 2>/dev/null || true)
if [ "$_ip" != "$DEMO_IP" ] || [ "$_prog" != "True" ]; then
  echo "✗ BEFORE state not ready (ingress IP='${_ip:-none}', Gateway Programmed='${_prog:-none}')." >&2
  echo "  Reset first:  ./9.cleanup_demo.sh  then  ./0.setup_before.sh" >&2
  exit 1
fi

# Colors (auto-disabled when piped / NO_COLOR set). We only tint the few tokens the audience should
# lock onto — the Ingress→Gateway shift and the single delete that triggers the handover.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RST=$'\033[0m'
  CYAN=$'\033[36m'; GREEN=$'\033[32m'; YEL=$'\033[33m'; RED=$'\033[31m'; INV=$'\033[7m'
else
  BOLD=; DIM=; RST=; CYAN=; GREEN=; YEL=; RED=; INV=
fi
OLD="${CYAN}"; NEW="${GREEN}"; TRIG="${BOLD}${YEL}"   # OLD=Ingress world, NEW=Gateway world, TRIG=the switch

step() { printf '\n%s %s %s\n' "${INV}${BOLD}${YEL}" "$1" "${RST}"; }   # read-only phase: yellow banner
# the ONE mutating step (deletes the controller): red reverse banner so it stands apart from the rest.
step_action() { printf '\n%s %s %s\n' "${INV}${BOLD}${RED}" "$1" "${RST}"; }
step_ok() { printf '\n%s %s %s\n' "${INV}${BOLD}${GREEN}" "$1" "${RST}"; }   # success phase (recovered): green banner
note() { printf '  %s%s%s\n' "${DIM}" "$1" "${RST}"; }                   # dim English presenter note
# _emit "<command>" : run it and frame every output line with a dim "│ " so the result reads as a
# distinct block, clearly separated from the command line above.
_emit() {
  printf '\n'   # break off the Enter prompt so the result block starts on its own line
  eval "$1" 2>&1 | while IFS= read -r _line; do
    printf '  %s│%s %s\n' "${DIM}" "${RST}" "$_line"
  done
}
# run "<colored display>" "<plain command to execute>" : show it, wait for Enter, then run it.
run() {
  printf '\n  %s▶%s %s\n' "${BOLD}${GREEN}" "${RST}" "$1"
  printf '    %s↵ Enter で実行 / press Enter to run%s ' "${DIM}" "${RST}"
  IFS= read -r _
  _emit "$2"
}
# run_action: same as run() but a RED ▶ marker — this is the one step that mutates the cluster.
run_action() {
  printf '\n  %s▶%s %s\n' "${BOLD}${RED}" "${RST}" "$1"
  printf '    %s↵ Enter で実行 (これが切替を起こします) / press Enter — this triggers the switch%s ' "${DIM}" "${RST}"
  IFS= read -r _
  _emit "$2"
}
# run_group "<disp1>" "<exec1>" "<disp2>" "<exec2>" ... : show ALL commands first, then ONE Enter
# runs them in sequence. For read-only "are we ready" checks that belong together (no need to
# pace them one Enter at a time).
run_group() {
  local i; local n=$#; local args=("$@")
  for ((i=0; i<n; i+=2)); do
    printf '\n  %s▶%s %s\n' "${BOLD}${GREEN}" "${RST}" "${args[i]}"
  done
  printf '    %s↵ Enter でまとめて実行 / press Enter to run all%s ' "${DIM}" "${RST}"
  IFS= read -r _
  for ((i=1; i<n; i+=2)); do
    _emit "${args[i]}"; echo
  done
}

printf '%s=== Live migration runner (Enter で1ステップずつ実行) ===%s\n' "${BOLD}${YEL}" "${RST}"
note "NGF Gateway is already converted + warm (from 0.setup_before.sh). The live handover is just an"
note "IP move (~1.6s), not a ~15s cold provisioning. Left pane (watch_curl) stays green the whole time."

step "[working] 【稼働中】いまは Ingress (ingress-nginx) が ${DEMO_IP} で配信しています。"
note "the current Ingress is serving on ${DEMO_IP} (left curl = green)"
run "kubectl get ${OLD}ingress${RST} jp-front" \
    "kubectl get ingress jp-front"

step "[convert] 【変換】ingress2gateway で Ingress を Gateway+HTTPRoute に変換します（黄色は警告ではなく注記）。"
note "show HOW the Gateway+HTTPRoute were generated from that Ingress."
note "  > Two WARNs appear, but both are informational notes, not errors. The HTTPRoute is perfect."
note "    (1) TLS self-signed (INGRESS-NGINX): fake 443 cert → not carried over. HTTP-only demo: irrelevant."
note "    (2) URL normalization (STANDARD_EMITTER): Gateway API has no field for it; NGF normalizes anyway."
run "ingress2gateway print --input-file ${HERE}/manifests/01-ingress.yaml --providers ${OLD}ingress-nginx${RST}" \
    "ingress2gateway print --input-file ${HERE}/manifests/01-ingress.yaml --providers ingress-nginx"

step "[ready] 【準備完了】NGF Gateway はすでに配備・起動済みで、同じ IP の割り当てを待っています（<pending>）。"
note "the Gateway (infra ns) is PROGRAMMED, its LB Service is <pending> while ingress holds ${DEMO_IP}."
run_group \
  "kubectl get ${NEW}gateway${RST} jp-gateway -n nginx-gateway" \
  "kubectl get gateway jp-gateway -n nginx-gateway" \
  "kubectl get ${NEW}httproute${RST} jp-front" \
  "kubectl get httproute jp-front" \
  "kubectl get svc -n nginx-gateway -l app.kubernetes.io/managed-by=ngf-nginx   ${DIM}# EXTERNAL-IP <pending>${RST}" \
  "kubectl get svc -n nginx-gateway -l app.kubernetes.io/managed-by=ngf-nginx"

step_action "[handover] 【切替】古い ingress-nginx を撤去すると ${DEMO_IP} が解放され、同じ IP を Gateway が即座に引き継ぎます（約1.6秒）。"
note "retire the old controller → it releases ${DEMO_IP}; MetalLB hands the SAME IP to the warm Gateway."
note "  (Deleting only the Ingress resource would NOT work — the controller keeps holding ${DEMO_IP}.)"
run_action "kubectl -n ingress-nginx ${BOLD}${RED}delete svc ingress-nginx-controller${RST}" \
    "kubectl -n ingress-nginx delete svc ingress-nginx-controller"

# recovered = success: green reverse banner.
step_ok "[recovered] 【復旧】Gateway が同じ IP (${DEMO_IP}) を保持しています。ダウンタイムなしで移行完了です。"
note "the Gateway now holds the same IP (${DEMO_IP}); left curl recovered on the same URL."
run "kubectl get ${NEW}gateway${RST} jp-gateway -n nginx-gateway -o wide" \
    "kubectl get gateway jp-gateway -n nginx-gateway -o wide"

printf '\n%s=== 完了 / done. reset: ./9.cleanup_demo.sh → ./0.setup_before.sh ===%s\n' "${BOLD}${GREEN}" "${RST}"
