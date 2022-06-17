#!/usr/bin/env bash

# download binary and move to bin 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
