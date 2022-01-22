#!/usr/bin/env bash

# istio 

## install istioctl 
curl -L  https://github.com/sysnet4admin/BB/raw/main/istioctl/v1.12.2/istioctl -o /usr/local/bin/istioctl
chmod 744 /usr/local/bin/istioctl

## istio auto completion 
curl -L  https://github.com/sysnet4admin/BB/raw/main/istioctl/v1.12.2/istioctl.bash -o /etc/bash_completion.d/istioctl.bash
echo 'source /etc/bash_completion.d/istioctl.bash' >> ~/.bashrc

## install instio components 
/usr/local/bin/istioctl install --set profile=demo -y

## install DashBoard 
kubectl apply -f ~/_Lecture_k8s_learning.kit/A/A.011/01.istio/sample/addons


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
