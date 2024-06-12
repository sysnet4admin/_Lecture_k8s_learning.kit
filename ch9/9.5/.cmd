kubectl describe pods -n metallb-system | grep Image:
cd _Lecture_k8s_learning.kit/ch9/9.5

metallb_unintaller.sh
kustomize_installer.sh

cd res/metallb-native 
kustomize create --autodetect
# kustomize create --namespace=metallb-system --resources res/metallb-native/namespace.yaml,res/metallb-native/metallb-native-v0.14.4.yaml

kustomize edit set image quay.io/metallb/speaker:v0.14.5
kustomize edit set image quay.io/metallb/controller:v0.14.5

cat kustomization.yaml

kustomize build
kustomize build | kubectl apply -f -
kubectl describe pods -n metallb-system | grep Image:

cd ../metallb-crd/
kubectl apply -f .

