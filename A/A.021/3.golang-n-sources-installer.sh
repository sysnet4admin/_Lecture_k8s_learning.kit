#!/usr/bin/env bash

# install sample apps made by golang 
kubectl apply -f https://raw.githubusercontent.com/datawire/edgey-corp-go/main/k8s-config/edgey-corp-web-app-no-mapping.yaml

# install golang 
apt-get install golang -y

# download golang source 
git clone https://github.com/datawire/edgey-corp-go.git

# set up auto refresh for go server 
go get github.com/pilu/fresh
cd edgey-corp-go/DataProcessingService/
$HOME/go/bin/fresh

