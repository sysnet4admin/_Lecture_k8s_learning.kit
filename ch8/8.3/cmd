[root@m-k8s ~]# kubectl describe pod kube-apiserver-m-k8s -n kube-system | grep -i author -F4
    Command:
      kube-apiserver
      --advertise-address=192.168.1.10
      --allow-privileged=true
      --authorization-mode=Node,RBAC
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --enable-admission-plugins=NodeRestriction
      --enable-bootstrap-token-auth=true
      --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt


[root@m-k8s 8.3]# k create namespace dev1
namespace/dev1 created
[root@m-k8s 8.3]# k create namespace dev2
namespace/dev2 created

[root@m-k8s 8.3]# k create serviceaccount dev1-hoon -n dev1
serviceaccount/dev1-hoon created
[root@m-k8s 8.3]# k create serviceaccount dev2-moon -n dev2
serviceaccount/dev2-moon created


[root@m-k8s ~]# k apply -f ns-sa-dev.yaml

[root@m-k8s ~]# k get sa -n dev1
NAME        SECRETS   AGE
default     1         7h30m
dev1-hoon   1         7h30m
[root@m-k8s ~]# k get sa -n dev2
NAME        SECRETS   AGE
default     1         7h30m
dev2-moon   1         7h30m

[root@m-k8s ~]# k apply -f role-get-dev1.yaml
[root@m-k8s ~]# k apply -f rolebidning-dev1.yaml

[root@m-k8s ~]# sh set-ctx-dev1.sh

[root@m-k8s ~]# k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          ctx-dev1-hoon                 kubernetes   dev1-set-hoon
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

k run nginx-admin --image=nginx -n dev1 <<< as a admin 
k run nginx-admin --image=nginx -n dev2

[root@m-k8s ~]# k config use-context ctx-dev1-hoon

k run nginx --image=nginx >>> error 
k run nginx --image=nginx -n dev1 

k get po -n dev1
k delete po nginx -n dev1 >>> error 

[root@m-k8s ~]# k config use-context kubernetes-admin@kubernetes
 


[root@m-k8s ~]# k apply -f role-gcr-dev2.yaml
[root@m-k8s ~]# k apply -f rolebidning-dev2.yaml

[root@m-k8s ~]# sh set-ctx-dev2.sh

[root@m-k8s ~]# k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          ctx-dev2-moon                 kubernetes   dev2-set-moon
          ctx-pod-admin                 kubernetes   set-pod-admin
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin


[root@m-k8s ~]# k config use-context ctx-dev2-moon

k run nginx --image=nginx -n dev2 
k get po -n dev2
k delete po nginx -n dev2

[root@m-k8s ~]# k config use-context kubernetes-admin@kubernetes


=== clusterrole ===

[root@m-k8s ~]# k apply -f role-k apply -f sa-pod-admin.yaml
[root@m-k8s ~]# k get sa
NAME                     SECRETS   AGE
default                  1         41d
nfs-client-provisioner   1         34d
sa-pod-admin             1         17m

[root@m-k8s ~]# k apply -f clusterrole.yaml
[root@m-k8s ~]# k apply -f clusterrolebinding.yaml


[root@m-k8s ~]# sh set-ctx-pod-admin.sh

[root@m-k8s ~]# k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          ctx-dev2-moon                 kubernetes   dev2-set-moon
          ctx-pod-admin                 kubernetes   set-pod-admin
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin


[root@m-k8s ~]# k config use-context ctx-pod-admin 

k delete po nginx -n dev1
k create deploy dpy-nginx --image=nginx 
k scale deploy dpy-nginx --replicas=3
k delete deploy dpy-nginx 

[root@m-k8s ~]# k config use-context kubernetes-admin@kubernetes



============== Reference Later========================
[root@m-k8s ~]# k config get-clusters
NAME
kubernetes

[root@m-k8s ~]# kubectl config set-credentials dev1-hoon -n dev1
User "dev1-hoon" set.


TOKENNAME=`kubectl -n dev1 get serviceaccount dev1-hoon -o jsonpath={.secrets[0].name}`
kubectl -n dev1 get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode
kubectl config set-credentials dev1-hoon --token=`kubectl -n dev1 get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`
kubectl config set-context ctx-dev1-hoon --cluster=kubernetes --user=dev1-hoon




[root@m-k8s ~]# k config set-context ctx-dev1-hoon --cluster=kuberntes --user=dev1-hoon
Context "ctx-dev1-hoon" created.
[root@m-k8s ~]# k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          ctx-dev1-hoon                 kuberntes    dev1-hoon
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

