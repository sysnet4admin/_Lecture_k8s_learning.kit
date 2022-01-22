This Source came from here and modify it for easy test purpose 
 - https://github.com/microservices-demo/microservices-demo

# Pre-Check Conditions 
- installed istioctl version: 1.12.2
- check istio & istioctl installed: `istioctl proxy-status` 
> If not, `istioctl install --set profile=demo -y`
- Create namespace: `kubectl create ns sock-shop` 
- Inject label: `kubectl label namespace sock-shop istio-injection=enabled` 

# Changement 
1. namespace add to sock-shop
2. `10-front-end-svc.yaml`   
  change from NodePort to LoadBalancer 
3. `07-catalogue-db-dep.yaml` 
  set db password