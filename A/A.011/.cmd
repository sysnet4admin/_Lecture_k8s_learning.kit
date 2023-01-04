01.istio configuraton 

# it can make to use but I made a script for it  
# export PATH=$PWD/bin:$PATH
sh ~/_Lecture_k8s_learning.kit/A/A.011/01.istio/cp-istioctl.sh

#(optional) if you want to check istio:
istioctl x precheck

# install istio components 
istioctl install --set profile=demo -y

kubectl create ns bookinfo 
kubectl label namespace bookinfo istio-injection=enabled 

kubectl apply -f ~/_Lecture_k8s_learning.kit/A/A.011/01.istio/samples/bookinfo

kubectl get svc istio-ingressgateway -n istio-system

# install DashBoard 
kubectl apply -f ~/_Lecture_k8s_learning.kit/A/A.011/01.istio/samples/addons

# basic command like below but I changed to LoadBalancer Thus...
# istioctl dashboard kiali --address 192.168.1.20&
# actually istioctl dashboard kiali --address 0.0.0.0& << determine by ports 
kubectl get svc -n istio-system 
# 192.168.1.20:20001

# run loadgenerator and check status on kiali's graph
sh ~/_Lecture_k8s_learning.kit/A/A.011/01.istio/loadgenerator.sh

11.online-boutique
kubectl create ns online-boutique
kubectl label namespace online-boutique istio-injection=enabled 

kubectl apply -f ~/_Lecture_k8s_learning.kit/A/A.011/11.online-boutique/release

# Before Starting delele all 
kubectl delete -f ~/_Lecture_k8s_learning.kit/A/A.011/01.istio/sample/bookinfo
kubectl delete -f ~/_Lecture_k8s_learning.kit/A/A.011/11.online-boutique/release

21.sock-shop
kubectl create ns sock-shop
kubectl label namespace sock-shop istio-injection=enabled 

kubectl apply -f ~/_Lecture_k8s_learning.kit/A/A.011/21.sock-shop/manifests
