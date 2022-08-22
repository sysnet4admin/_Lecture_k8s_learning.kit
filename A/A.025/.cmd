# deploy dual container to check pause's sharing 
k apply -f dual-cnt.yaml 

# check container ID 
k describe po dual-cnt-dc66f778c-4zzv6 | grep "Container ID:"

# connect w3-k8s 
ssh or direct connect

## check namespace 
ctr ns ls
ctr -n k8s.io i ls 
ctr -n k8s.io i ls | grep pause 

ctr -n k8s.io c ls
ctr -n k8s.io c ls | grep net
ctr -n k8s.io c ls | grep dns

# compare between ctr's PID and ps's PID (i.e. child ps)
ctr -n k8s.io t ls
ps axf
ps axfj 
ps --ppid <PID> -o pid,ppid,cmd
# install pstree 
yum install psmisc -y
pstree 
pstree 1 
pstree -a <PID>
pstree -p 1 
pstree -ap 1 
pstree -ap <PID>

# check each of pid by lsns -p
pstree <PID>
lsns -p 1
ls -l /proc/ns/1 
ls -l /proc/ns/<init's PID>
ls -l /proc/ns/<containerd-shim PID> # same as init's PID
ls -l /proc/ns/<pause PID>
ls -l /proc/ns/<child PID>
ls -l /proc/ns/<child PID>
# lsns -p <main pause>
# lsns -p <child ps>
# lsns -p <child ps>

# connect both container to check ip addr is same 
ctr -n k8s.io c ls | grep net
ctr -n k8s.io task exec -t --exec-id <name> <TASK ID> /bin/bash
ctr -n k8s.io c ls | grep dns
ctr -n k8s.io task exec -t --exec-id <name> <TASK ID> /bin/bash

# from w3-k8s to check ip address which is cotainer's network range. 
ip link show 
ip route 

