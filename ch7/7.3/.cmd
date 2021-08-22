[root@m-k8s ~]# cp static-pod.yaml /etc/kubernetes/manifests/


[root@m-k8s ~]# scp static-pod.yaml w1-k8s:/etc/kubernetes/manifests/
The authenticity of host 'w1-k8s (192.168.1.101)' can't be established.
ECDSA key fingerprint is SHA256:l6XikZFgOibzSygqZ6+UYHUnEmjFEFhx7PpZw0I3WaM.
ECDSA key fingerprint is MD5:09:74:43:ef:38:3e:36:a1:7e:51:76:1a:ac:2d:7e:0c.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'w1-k8s,192.168.1.101' (ECDSA) to the list of known hosts.
root@w1-k8s's password:
static-pod.yaml                                                                                                                                                                  100%  111    36.3KB/s   00:00


static's configuration: /var/lib/kubelet/config.yaml
