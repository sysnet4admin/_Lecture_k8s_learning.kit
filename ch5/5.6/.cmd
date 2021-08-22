nfs-exporter.sh dynamic-vol  
cat /etc/exports

k apply -f ~/_Lecture_k8s_learning.kit/ch5/5.6/nfs-subdir-external-provisioner
k apply -f ~/_Lecture_k8s_learning.kit/ch5/5.6/storageclass.yaml
k apply -f ~/_Lecture_k8s_learning.kit/ch5/5.6/persistentvolumeclaim-dynamic.yaml
k apply -f ~/_Lecture_k8s_learning.kit/ch5/5.6/deploy-pvc.yaml
