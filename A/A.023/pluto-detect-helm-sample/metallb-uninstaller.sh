# raw_address for gitcontent
raw_git="raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/CNI/archived" 

# config metallb for LoadBalancer service > upgrade
kubectl delete -f https://$raw_git/svc/metallb-0.10.2.yaml
