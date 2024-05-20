
# install metallb for the LoadBalancer svc 
k apply -f metallb-native-v0.14.4.yaml
k get crd | grep -i metallb 

# create CRD's configurations 
k apply -f metallb-l2mode.yaml
k apply -f metallb-iprange.yaml

# and then create the LoadBalancer svc per each 
