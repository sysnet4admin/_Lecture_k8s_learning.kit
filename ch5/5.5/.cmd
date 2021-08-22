nfs-exporter.sh pvc-vol  
cat /etc/exports

k apply -f ~/_Lecture_k8s_learning.kit/ch5/5.5/persistentvolume-nfs.yaml
k get pv 

k apply -f ~/_Lecture_k8s_learning.kit/ch5/5.5/persistentvolumeclaim-nfs.yaml
k get pvc 

k apply -f ~/_Lecture_k8s_learning.kit/ch5/5.5/deploy-pvc.yaml 

kubectl get pods -o wide
curl <IP>

kubectl exec dpy-chk-log-<ReplicaSet>-<HASH> -it -- /bin/bash
kubectl delete pod dpy-chk-log-<ReplicaSet>-<HASH>
kubectl exec dpy-chk-log-<ReplicaSet>-<HASH> -it -- /bin/bash
