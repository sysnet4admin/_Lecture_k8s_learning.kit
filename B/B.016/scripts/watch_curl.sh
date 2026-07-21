#!/usr/bin/env bash
# Left pane — continuous curl that never stops during the demo. Success/failure proves
# working→broken→recovered in real time.
DEMO_IP="${DEMO_IP:-192.168.1.12}"
HOST="${HOST:-demo.kubecon.jp}"
while true; do
  ts=$(date +%H:%M:%S)
  body=$(curl -s --max-time 1 --resolve "$HOST:80:$DEMO_IP" "http://$HOST/" 2>/dev/null) || body=""
  # Labels are the same width (Okay/FAIL = 4 chars + a single-width mark) so the body column
  # stays aligned and the broken window is easy to read at a glance.
  if [ -n "$body" ]; then
    printf '\033[32m[%s] Okay \xe2\x9c\x93  %s\033[0m\n' "$ts" "$body"          # green ✓ = working/recovered
  else
    printf '\033[31m[%s] FAIL \xe2\x9c\x97  (no response)\033[0m\n' "$ts"       # red ✗ = broken
  fi
  sleep 0.5
done
