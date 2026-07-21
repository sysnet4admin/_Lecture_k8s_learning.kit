#!/usr/bin/env bash

# init kubernetes (w/ containerd)
# kube-proxy is kept (standard): Calico CNI does not replace it.
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
             --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.1.160 \
             --cri-socket=unix:///run/containerd/containerd.sock

# config for master node only
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# CNI: Calico v3.31.2 (same recipe as the All-in-one lab, _Lecture_k8s_learning.kit/B.001/U).
# LoadBalancer IP assignment is handled by MetalLB (see metallb.sh), not the CNI —
# so the demo's `metallb.io/loadBalancerIPs` annotations stay unchanged.
# Pin the pod pool to the kubeadm --pod-network-cidr (172.16.0.0/16) so it never
# overlaps the node/MetalLB network (192.168.1.0/24).
CNI_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/CNI"
curl -fsSL "$CNI_ADDR/calico-quay-v3.31.2.yaml" -o /tmp/calico.yaml
sed -i \
  -e 's|^            # - name: CALICO_IPV4POOL_CIDR|            - name: CALICO_IPV4POOL_CIDR|' \
  -e 's|^            #   value: "192.168.0.0/16"|              value: "172.16.0.0/16"|' \
  /tmp/calico.yaml
kubectl apply -f /tmp/calico.yaml

# wait for Calico to be ready before declaring the CP node done
kubectl -n kube-system rollout status ds/calico-node --timeout=300s || true

# kubectl completion on bash-completion dir
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k
echo 'alias k=kubectl'               >> ~/.bashrc
echo "alias kg='kubectl get'"        >> ~/.bashrc
echo "alias ka='kubectl apply -f'"   >> ~/.bashrc
echo "alias kd='kubectl delete -f'"  >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# extended k8s certifications all
git clone https://github.com/yuyicai/update-kube-cert.git /tmp/update-kube-cert
chmod 755 /tmp/update-kube-cert/update-kubeadm-cert.sh
/tmp/update-kube-cert/update-kubeadm-cert.sh all --cri containerd
rm -rf /tmp/update-kube-cert
echo "Wait 10 seconds for restarting the Control-Plane Node..." ; sleep 10
