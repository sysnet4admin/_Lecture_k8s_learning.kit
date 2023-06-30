# check certificates
kubeadm certs check-expiration
cat /etc/kubernetes/pki/apiserver.crt | openssl x509  -noout -text | grep ' Not '

# renew certificates 
kubeadm certs renew all

# extend 10 years for certificates 
git clone https://github.com/yuyicai/update-kube-cert.git
cd update-kube-cert
chmod 755 update-kubeadm-cert.sh
./update-kubeadm-cert.sh all

