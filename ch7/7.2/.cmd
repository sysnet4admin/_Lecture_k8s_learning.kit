k run nginx --image=nginx 
k create deploy nginx --image=nginx 

[root@m-k8s ~]# k get po -l run=nginx 
[root@m-k8s ~]# k get po -l app=nginx

[root@m-k8s ~]# k label pod nginx purpose=web
pod/nginx labeled
[root@m-k8s ~]# k get po nginx --show-labels
NAME    READY   STATUS    RESTARTS   AGE   LABELS
nginx   1/1     Running   0          15m   purpose=web,run=nginx
[root@m-k8s ~]# k label pod nginx purpose-
pod/nginx labeled
[root@m-k8s ~]# k get po nginx --show-labels
NAME    READY   STATUS    RESTARTS   AGE   LABELS
nginx   1/1     Running   0          15m   run=nginx

