This Source came from here and modify it for easy test purpose 
 - https://github.com/GoogleCloudPlatform/microservices-demo

# Pre-Check Conditions 
- installed istioctl version: 1.12.2
- check istio & istioctl installed: `istioctl proxy-status` 
> If not, `istioctl install --set profile=demo -y`
- Create namespace: `kubectl create ns online-boutique` 
- Inject label: `kubectl label namespace online-boutique istio-injection=enabled` 

# Changement 
1. namespace add to online-boutique
2. loadgenerator's users from 10 to 1  