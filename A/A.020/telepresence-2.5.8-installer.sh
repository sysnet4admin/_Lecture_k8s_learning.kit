#!/usr/bin/env bash

# install pre-requirement  for centos 
yum install python3 sshfs -y
echo "successfully installed python3 sshfs"

# download binary and chmod to run 
curl -fL https://app.getambassador.io/download/tel2/linux/amd64/2.5.8/telepresence -o /usr/local/bin/telepresence
chmod a+x /usr/local/bin/telepresence

# install traffic-manager 
helm repo add datawire  https://app.getambassador.io
helm repo update
helm install traffic-manager datawire/telepresence \
--create-namespace \
--namespace ambassador \
--set image.tag=2.5.8  