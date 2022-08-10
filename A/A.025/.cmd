# deploy dual container to check pause's sharing 
k apply -f dual-cnt.yaml 

# check container ID 
k describe po dual-cnt-dc66f778c-4zzv6 | grep "Container ID:"

# connect w3-k8s 
ssh or diret

## check namespace 
ctr ns ls
ctr -n k8s.io i ls 

ctr -n k8s.io c ls
ctr -n k8s.io c ls | grep sys
ctr -n k8s.io c ls | grep dns

# compare between ctr's PID and ps's PID (i.e. child ps)
ctr -n k8s.io t ls
ps axf
ps --ppid <PID> -o pid,ppid,cmd
# install pstree 
yum install psmisc -y
pstree 
pstree -p 1 
pstree -ap 1 
pstree -ap <PID>

# check each of pid by lsns -p
lsns -p <main pause>
lsns -p <child ps>
lsns -p <child ps>

# connect both container to check ip addr is same 
ctr -n k8s.io task exec -t --exec-id <name> <TASK ID> /bin/bash
ctr -n k8s.io task exec -t --exec-id <name> <TASK ID> /bin/bash

# from w3-k8s to check ip address which is cotainer's network range. 
ip link show 
ip route 

