kubectl describe pods -n metallb-system | grep Image:
cd _Lecture_k8s_learning.kit/ch9/9.5

metallb-unintaller.sh
kustomize-installer.sh

cd res
kustomize create --autodetect
# kustomize create --namespace=metallb-system --resources res/namespace.yaml,res/metallb.yaml,res/metallb-l2config.yaml,res/metallb-memberlist.yaml 

kustomize edit set image quay.io/metallb/speaker:v0.10.2
kustomize edit set image quay.io/metallb/controller:v0.10.2

cat kustomization.yaml

kustomize build
kustomize build | kubectl apply -f -
kubectl describe pods -n metallb-system | grep Image:
