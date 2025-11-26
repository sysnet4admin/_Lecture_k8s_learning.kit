
# From file
ingress2gateway print --providers=ingress-nginx --input-file=ingress.yaml -A > gateway.yaml

# From cluster
ingress2gateway print --providers=ingress-nginx --all-namespaces > gateway.yaml


# 1. Gateway API CRDs (standard channel)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

k get crd  | grep gateway

# 2. NGINX Gateway Fabric CRDs
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.2.1/deploy/crds.yaml

k get crd | grep nginx

# 3. NGINX Gateway Fabric (default)
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.2.1/deploy/default/deploy.yaml

k get all -n nginx-gateway
k get gatewayclasses

---

kubectl apply -f gateway.yaml
gateway.gateway.networking.k8s.io/nginx created
httproute.gateway.networking.k8s.io/nginx-ingress-all-hosts created

kubectl get gateway
NAME    CLASS   ADDRESS        PROGRAMMED   AGE
nginx   nginx   192.168.1.11   True         32s

kubectl get httproute
NAME                      HOSTNAMES   AGE
nginx-ingress-all-hosts               55s

---

GATEWAY_IP=$(kubectl get gateway nginx -o jsonpath='{.status.addresses[0].value}')
echo ${GATEWAY_IP}
# 192.168.1.11

# Test 
curl -s http://${GATEWAY_IP}/
curl -s http://${GATEWAY_IP}/hn
curl -s http://${GATEWAY_IP}/ip




