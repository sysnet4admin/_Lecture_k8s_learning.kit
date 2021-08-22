~/_Lecture_k8s_learning.kit/ch9/9.6/get_helm.sh

helm repo add edu https://k8s-edu.github.io/helm-charts
helm repo update 
helm search repo

k get po -n metallb-system
~/_Lecture_k8s_learning.kit/ch9/9.6/metallb-unintaller.sh
k get po -n metallb-system

cat ~/_Lecture_k8s_learning.kit/ch9/9.6/metallb-intaller-by-helm.sh
cat ~/_Lecture_k8s_learning.kit/ch9/9.6/l2-config-by-helm.yaml

helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system \
     --set controller.image.tag=v0.10.2 \
     --set speaker.image.tag=v0.10.2 \
     -f ~/_Lecture_k8s_learning.kit/ch9/9.6/l2-config-by-helm.yaml

helm list -n metallb-system
helm list -A
k get po -n metallb-system

k apply -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml

####

k get pv,pvc
k get storageclasses.storage.k8s.io

cat ~/_Lecture_k8s_learning.kit/ch9/9.6/nfs-provisioner-uninstaller.sh
~/_Lecture_k8s_learning.kit/ch9/9.6/nfs-provisioner-uninstaller.sh

k get pv,pvc
k get storageclasses.storage.k8s.io

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

####
helm uninstall metallb 

helm install metallb edu/metallb \
     --create-namespace \
     --namespace=metallb-system \
     -f ~/_Lecture_k8s_learning.kit/ch9/9.6/l2-config-by-helm.yaml

k apply -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml

k delete -f ~/_Lecture_k8s_learning.kit/ch9/9.6/deploy-w-pvc-svc.yaml
