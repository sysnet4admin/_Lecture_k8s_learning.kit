# Running kubespray 
1. login m11-k8s
```bash 
$ sh auto_pass.sh
# ansible-playbook kubespray/cluster.yml -i ansible_hosts.ini
```
Note: if you need to add or remove for hosts, please modify ansible_hosts.ini manually.