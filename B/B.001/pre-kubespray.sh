#!/usr/bin/env bash

yum install python36 python36-pip git -y

# git clone https://github.com/kubernetes-sigs/kubespray.git
# to avoid kubectl missing error
git clone -b release-2.17 https://github.com/kubernetes-sigs/kubespray.git
sudo mv kubespray /root

# docker? it is not pre-requirement but if it is not exist, it will fail. 
# TASK [download : download_container | Download image if required] 
# <snipped>
#fatal: [w1-k8s -> 192.168.1.11]: FAILED! => {"attempts": 4, "changed": false, "cmd": "/usr/bin/docker pull docker.io/calico/node:v3.7.3", "msg": "[Errno 2] 그런 파일이나 디렉터리가 없습니다", "rc": 2}
#fatal: [w2-k8s -> 192.168.1.11]: FAILED! => {"attempts": 4, "changed": false, "cmd": "/usr/bin/docker pull docker.io/calico/node:v3.7.3", "msg": "[Errno 2] 그런 파일이나 디렉터리가 없습니다", "rc": 2}

# remain legacy due to no issue so far 
yum install docker -y
systemctl enable --now docker

# other ansible, jinja2 netaddr will be installed by requirement.txt (2021.09.18)
#ansible==3.4.0
#ansible-base==2.10.11
#cryptography==2.8
#jinja2==2.11.3
#netaddr==0.7.19
#pbr==5.4.4
#jmespath==0.9.5
#ruamel.yaml==0.16.10
#ruamel.yaml.clib==0.2.2
#MarkupSafe==1.1.1
cat <<EOF >  /root/requirements.txt
ansible==3.4.0
ansible-base==2.10.11
cryptography==2.8
jinja2==2.11.3
netaddr==0.7.19
pbr==5.4.4
jmespath==0.9.5
ruamel.yaml==0.16.10
ruamel.yaml.clib==0.2.2
MarkupSafe==1.1.1
EOF
pip3.6 install -r /root/requirements.txt

# fixed k8s version
mkdir /root/group_vars
cat <<EOF >  /root/group_vars/all
kube_version: v1.22.1
EOF

# add ansible hosts file 
cat <<EOF >  /root/ansible_hosts.ini
[all]
m11-k8s ansible_host=192.168.1.11 ip=192.168.1.11
m12-k8s ansible_host=192.168.1.12 ip=192.168.1.12
m13-k8s ansible_host=192.168.1.13 ip=192.168.1.13
w101-k8s ansible_host=192.168.1.101 ip=192.168.1.101
w102-k8s ansible_host=192.168.1.102 ip=192.168.1.102
w103-k8s ansible_host=192.168.1.103 ip=192.168.1.103
w104-k8s ansible_host=192.168.1.104 ip=192.168.1.104
w105-k8s ansible_host=192.168.1.105 ip=192.168.1.105
w106-k8s ansible_host=192.168.1.106 ip=192.168.1.106
w107-k8s ansible_host=192.168.1.107 ip=192.168.1.107
w108-k8s ansible_host=192.168.1.108 ip=192.168.1.108
w109-k8s ansible_host=192.168.1.109 ip=192.168.1.109


[etcd]
m11-k8s 
m12-k8s 
m13-k8s 

[kube-master]
m11-k8s 
m12-k8s 
m13-k8s 

[kube-node]
w101-k8s 
w102-k8s 
w103-k8s 
w104-k8s 
w105-k8s 
w106-k8s 
w107-k8s 
w108-k8s 
w109-k8s 


[calico-rr]

[k8s-cluster:children]
kube-master
kube-node
calico-rr
EOF
