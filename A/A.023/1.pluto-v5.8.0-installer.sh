#!/usr/bin/env bash

VER="5.8.0"

# install pre-requirement  for centos 
if [[ "$(awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release)" = *"CentOS"* ]]; then 
  yum install python3 sshfs -y
  echo "successfully installed python3 sshfs on CentOS"
fi 


# download binary and move to bin 
curl -LO https://github.com/FairwindsOps/pluto/releases/download/v$VER/pluto_$VER_linux_amd64.tar.gz
tar xvfz pluto_5.8.0_linux_amd64.tar.gz -C /tmp
mv /tmp/pluto /usr/local/bin

# download binary and chmod to run 
curl -fL https://app.getambassador.io/download/tel2/linux/amd64/$VER/telepresence -o /usr/local/bin/telepresence
chmod a+x /usr/local/bin/telepresence

# install traffic-manager 
helm repo add datawire  https://app.getambassador.io
helm repo update
helm install traffic-manager datawire/telepresence \
--create-namespace \
--namespace ambassador \
--set image.tag=$VER
