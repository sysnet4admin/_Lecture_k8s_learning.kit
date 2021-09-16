# Hot to install and run kubernetes by kubespray 

### Provisioning VM(m3+w9) by vagrant (require 24GiB or above Memories) 
``` bash 
$ vagrant up 
```

### login m11-k8s
```bash 
$ sh auto_pass.sh
$ ansible-playbook kubespray/cluster.yml -i ansible_hosts.ini
```

Note: if you need to add or remove for the hosts, please modify ansible_hosts.ini manually.