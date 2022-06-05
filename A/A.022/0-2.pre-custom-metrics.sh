#!/usr/bin/env bash

# install jq in CentOS and Ubuntu distro linux  
if [[ "$(awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release)" = *"CentOS"* ]]; then 
  yum install jq -y
  echo "successfully installed jq on CentOS"
elif [[ "$(awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release)" = *"Ubuntu"* ]]; then
  apt-get install jq -y
  echo "successfully installed jq on CentOS"  
else
  echo "Please install jq manually"
fi 

# install cfssl cfssljson for gencerts
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64 -o /usr/local/bin/cfssl
chmod +x /usr/local/bin/cfssl
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64 -o /usr/local/bin/cfssljson
chmod +x /usr/local/bin/cfssljson

# create gencerts for prometheus adapter 
# source from: https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/62fff622e9900fade8aecbd02bc9c557b736ef85/experimental/custom-metrics-api/gencerts.sh
export PURPOSE=metrics
openssl req -x509 -sha256 -new -nodes -days 365 -newkey rsa:2048 -keyout ${PURPOSE}-ca.key -out ${PURPOSE}-ca.crt -subj "/CN=ca"
echo '{"signing":{"default":{"expiry":"43800h","usages":["signing","key encipherment","'${PURPOSE}'"]}}}' > "${PURPOSE}-ca-config.json"

export SERVICE_NAME=custom-metrics-apiserver
export ALT_NAMES='"custom-metrics-apiserver.monitoring","custom-metrics-apiserver.monitoring.svc"'
echo '{"CN":"'${SERVICE_NAME}'","hosts":['${ALT_NAMES}'],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=metrics-ca.crt -ca-key=metrics-ca.key -config=metrics-ca-config.json - | cfssljson -bare apiserver

# create cm-adapter-serving-certs.yaml 
cat <<-EOF > cm-adapter-serving-certs.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cm-adapter-serving-certs
  namespace: custom-metrics
data:
  serving.crt: $(cat apiserver.pem | base64 --wrap=0)
  serving.key: $(cat apiserver-key.pem | base64 --wrap=0)
EOF

# create name for custom-metrics
kubectl create ns custom-metrics
# create secret info in custom-metrics namespace 
kubectl apply -f cm-adapter-serving-certs.yaml 


