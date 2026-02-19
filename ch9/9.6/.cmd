# helm 
~/_Lecture_k8s_learning.kit/ch9/9.6/get_helm.sh

helm repo add edu https://k8s-edu.github.io/Lkv1_main/helm-charts/v1.30/k8s-adv/ 
helm repo update 
helm search repo

# metallb version 0.14.5 by helm 
k get po -n metallb-system
~/_Lecture_k8s_learning.kit/ch9/9.6/uninstaller/metallb_unintaller.sh
k get po -n metallb-system

cat ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb_intaller.sh
cat ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb-crds/metallb-l2mode.yaml 
cat ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb-crds/metallb-iprange.yaml 

~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb_intaller.sh
helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system \
     --set speaker.frr.enabled=false \
     --set controller.image.tag=v0.14.5 \
     --set speaker.image.tag=v0.14.5

echo "\nWait 30 seconds for helm's CRDs deployed completely" ; sleep 30
kubectl apply -f ~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/metallb-crds/


helm list -n metallb-system
helm list -A
k get po -n metallb-system

k apply -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml

# nfs-provisioner by helm 
## pre-requirement "5.6/nfs_exporter.sh dynamic-vol"

k get pv,pvc
k get storageclasses.storage.k8s.io

cat ~/_Lecture_k8s_learning.kit/ch9/9.6/uninstaller/nfs-provisioner_uninstaller.sh
~/_Lecture_k8s_learning.kit/ch9/9.6/uninstaller/nfs-provisioner_uninstaller.sh

k get pv,pvc
k get storageclasses.storage.k8s.io

~/_Lecture_k8s_learning.kit/ch9/9.6/installer-by-helm/nfs-provisioner_installer.sh
helm install nfs-provisioner edu/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.10 \
    --set nfs.path=/nfs_shared/dynamic-vol \
    --set storageClass.name=managed-nfs-storage     

k get pv,pvc
k get storageclasses.storage.k8s.io
helm list

k delete -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml
k apply -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml

k delete -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml

# metallb default version by helm (optional) 
helm uninstall metallb 
helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system 

k apply -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml

k delete -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml
