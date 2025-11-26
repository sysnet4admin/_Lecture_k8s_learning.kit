#!/usr/bin/env bash

curl -LO "https://github.com/kubernetes-sigs/ingress2gateway/releases/download/v0.4.0/ingress2gateway_$(uname -s)_$(uname -m | sed 's/aarch64/arm64/').tar.gz" \
  && tar -xzf ingress2gateway_*.tar.gz \
  && sudo mv ingress2gateway /usr/local/bin/ \
  && rm -f ingress2gateway_*.tar.gz \
  && command -v ingress2gateway && echo "ingress2gateway installed successfully"

