#!/usr/bin/env bash

# add docker-ce repo
yum install yum-utils -y 
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# install docker
yum install docker-ce-$1 docker-ce-cli-$1 containerd.io-$2 -y

# Ready to install for k8s
systemctl enable --now docker
