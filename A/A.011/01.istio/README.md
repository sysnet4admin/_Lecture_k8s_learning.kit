This Source came from here and modify it for easy test purpose 
 - https://istio.io/latest/docs/setup/getting-started/

# Pre-Check Conditions 
- istioctl version: 1.12.2
- istio & istioctl installed: `istioctl proxy-status` 
> if not, `istioctl install --set profile=demo -y`
- kubectl create ns bookinfo 
- kubectl label namespace bookinfo istio-injection=enabled 

# Changement 
`kiali.yaml`
1. from ClusterIP to LoadBalancer  
2. static ip 
  type: LoadBalancer                   # Change from clusterIP to LoadBalancer
  loadBalancerIP: 192.168.1.20         # Static IP