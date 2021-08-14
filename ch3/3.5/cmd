k apply -f simple-wo-command.yaml
k get po -w

k apply -f simple-command.yaml
k get po -w
k exec simple-command -it -- nslookup kubernetes

k run net --image=sysnet4admin/net-tools -- sleep 3600
===

k apply -f multiple-command-v1.yaml
k logs multiple-command-v1

k apply -f multiple-command-v2.yaml
k logs multiple-command-v2

k apply -f multiple-command-v3.yaml
k logs multiple-command-v3

k apply -f multiple-command-w-args
k logs multiple-command-w-args