#!/usr/bin/env bash

VER="5.8.0"

# download binary and move to bin 
curl -LO https://github.com/FairwindsOps/pluto/releases/download/v$VER/pluto_$VER_linux_amd64.tar.gz
tar xvfz pluto_5.8.0_linux_amd64.tar.gz -C /tmp
mv /tmp/pluto /usr/local/bin

