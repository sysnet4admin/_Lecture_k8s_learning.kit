### 실습 랩 All-in-one (v1.23.3)
노드의 Runtime (`containerd`)상태는 다음과 같습니다.
```bash
[root@m-k8s ~]# k get node -o wide 
NAME     STATUS   ROLES                  AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION                CONTAINER-RUNTIME
m-k8s    Ready    control-plane,master   10m     v1.23.3   192.168.1.10    <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   containerd://1.4.12
w1-k8s   Ready    <none>                 6m35s   v1.23.3   192.168.1.101   <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   containerd://1.4.12
w2-k8s   Ready    <none>                 3m29s   v1.23.3   192.168.1.102   <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   containerd://1.4.12
w3-k8s   Ready    <none>                 22s     v1.23.3   192.168.1.103   <none>        CentOS Linux 7 (Core)   3.10.0-1127.19.1.el7.x86_64   containerd://1.4.12
```
