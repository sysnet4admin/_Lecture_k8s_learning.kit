This Source came from here and modify it for easy test purpose 
 - https://istio.io/latest/docs/setup/getting-started/
istio version: 1.12.2

# Changement 

kiali.yaml 
from ClusterIP to LoadBalancer

  ports:
  - name: http
    protocol: TCP
    port: 80                           # Change from 20001 to 80 
  - name: http-metrics
    protocol: TCP
    port: 9090
  selector:
    app.kubernetes.io/name: kiali
    app.kubernetes.io/instance: kiali
  type: LoadBalancer                   # Change from clusterIP to LoadBalancer
  loadBalancerIP: 192.168.1.20         # Static IP