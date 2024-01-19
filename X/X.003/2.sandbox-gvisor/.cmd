# Install and configure gVisor

scp gvisor-install.sh node01:~
ssh node01
    ./gvisor-install.sh
    systemctl restart kubelet 

# Create RuntimeClass and Pod to use gVisor

# RuntimeClass

apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc

# Pod 

apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc

# test 

controlplane $ k exec sec -- dmesg
[   0.000000] Starting gVisor...
[   0.470146] Digging up root...
[   0.555459] Adversarially training Redcode AI...
[   0.645070] Searching for socket adapter...
[   1.079022] Accelerating teletypewriter to 9600 baud...
[   1.308783] Granting licence to kill(2)...
[   1.758330] Gathering forks...
[   2.128628] Segmenting fault lines...
[   2.192727] Letting the watchdogs out...
[   2.607950] Synthesizing system calls...
[   2.833566] Consulting tar man page...
[   2.853361] Setting up VFS...
[   3.193971] Setting up FUSE...
[   3.316403] Ready!


