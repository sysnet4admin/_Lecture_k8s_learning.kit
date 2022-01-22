#!/usr/bin/env bash

# istio 

## install istioctl 
curl -L  https://github.com/sysnet4admin/BB/raw/main/istioctl/v1.12.2/istioctl -o /usr/local/bin/istioctl
chmod 744 /usr/local/bin/istioctl

## istio auto completion 
curl -L  https://github.com/sysnet4admin/BB/raw/main/istioctl/v1.12.2/istioctl.bash -o /etc/bash_completion.d/istioctl.bash
echo 'source /etc/bash_completion.d/istioctl.bash' >> ~/.bashrc

cat <<EOF > $HOME/istio_installer.sh
istioctl install --set profile=demo -y
kubectl apply -f ~/_Lecture_k8s_learning.kit/A/A.011/01.istio/samples/addons
EOF

# background istio_installer.sh after 20min
#bash -c 'sleep 1200; sh /tmp/istio_installer.sh' &

# injection to istio for each lab

## bookinfo
kubectl create ns bookinfo 
kubectl label namespace bookinfo istio-injection=enabled 

## online-boutique
kubectl create ns online-boutique
kubectl label namespace online-boutique istio-injection=enabled

## sock-shop
kubectl create ns sock-shop
kubectl label namespace sock-shop istio-injection=enabled 
