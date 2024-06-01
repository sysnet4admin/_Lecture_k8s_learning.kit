#!/usr/bin/env bash

THIRD_OCTEC="56"

# delete unused nodes 
kubectl delete node w2-k8s
kubectl delete node w3-k8s 

# install sshapass to skip the password prompt  
apt-get install sshpass -y 

# cp-k8s (2cores,4GB)
ADD_ETH2="echo '
    eth2:
      addresses:
      - 192.168.$THIRD_OCTEC.10/24
' >> /etc/netplan/50-vagrant.yaml
netplan apply 
"        
sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no root@cp-k8s "${ADD_ETH2}"

# w1-k8s (4cores,8GB) 
ADD_ETH2="echo '
    eth2:
      addresses:
      - 192.168.$THIRD_OCTEC.101/24
' >> /etc/netplan/50-vagrant.yaml
netplan apply 
"        
sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no root@w1-k8s "${ADD_ETH2}"

# it must run since calico-node is working properly 
kubectl replace -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: k8s-svc-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.$THIRD_OCTEC.11-192.168.$THIRD_OCTEC.99
EOF

