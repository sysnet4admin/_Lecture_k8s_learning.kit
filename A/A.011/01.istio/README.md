This Source came from here and modify it for easy test purpose 
 - https://istio.io/latest/docs/setup/getting-started/
istio version: 1.12.2

# Changement 

kiali.yaml 
1. from ClusterIP to LoadBalancer  
2. static ip 
  type: LoadBalancer                   # Change from clusterIP to LoadBalancer
  loadBalancerIP: 192.168.1.20         # Static IP