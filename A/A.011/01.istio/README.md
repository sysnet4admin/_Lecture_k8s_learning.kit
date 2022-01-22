This Source came from here and modify it for easy test purpose 
 - https://istio.io/latest/docs/setup/getting-started/

# Pre-Check Conditions 
- installed istioctl version: 1.12.2
- check istio & istioctl installed: `istioctl proxy-status` 
> If not, `istioctl install --set profile=demo -y`
- Create namespace: `kubectl create ns bookinfo` 
- Inject label: `kubectl label namespace bookinfo istio-injection=enabled` 

# Changement 
`kiali.yaml`
1. From ClusterIP to LoadBalancer  
2. Static IP   
    1. type: LoadBalancer                   # Change from clusterIP to LoadBalancer   
    2. loadBalancerIP: 192.168.1.20         # Static IP