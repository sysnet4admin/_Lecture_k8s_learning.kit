### 실습 랩 All-in-one (v1.23.1)
노드의 Runtime (`dockershim`)상태는 다음과 같습니다.   
```bash
[root@m-k8s ~]# k get node -o wide 
NAME     STATUS   ROLES                  AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION                CONTAINER-RUNTIME
m-k8s    Ready    control-plane,master   12m     v1.23.1   192.168.1.10    <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   docker://20.10.12
w1-k8s   Ready    <none>                 8m54s   v1.23.1   192.168.1.101   <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   docker://20.10.12
w2-k8s   Ready    <none>                 5m9s    v1.23.1   192.168.1.102   <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   docker://20.10.12
w3-k8s   Ready    <none>                 67s     v1.23.1   192.168.1.103   <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   docker://20.10.12
```
