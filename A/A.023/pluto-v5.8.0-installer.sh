#!/usr/bin/env bash

# download binary and move to bin 
curl -LO https://github.com/FairwindsOps/pluto/releases/download/v5.8.0/pluto_5.8.0_linux_amd64.tar.gz
tar xvfz pluto_5.8.0_linux_amd64.tar.gz -C /tmp
mv /tmp/pluto /usr/local/bin

