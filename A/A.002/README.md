# How to install and run kubernetes by kubespray 

### Provisioning VMs(m3+w9) by vagrant (require 24GiB or above Memories) 
``` bash 
$ vagrant up 
```

### Deploy kubernetes cluster by kubesprary 
1. connect to m11-k8s 
2. run this command on m11-k8s
```bash 
$ sh auto_pass.sh
$ ansible-playbook kubespray/cluster.yml -i ansible_hosts.ini
```

Note: 
 - If you need to add or remove for the hosts, please modify ansible_hosts.ini manually.
 - If you want to change kubernetes version, please change kube_version on `group_vars/all` 