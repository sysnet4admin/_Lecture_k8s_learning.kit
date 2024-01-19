# Deployment is not coming up, find the error and fix it

controlplane $ k get po -n application1
NAME                   READY   STATUS                       RESTARTS   AGE
api-86549f8c79-gzfmj   0/1     CreateContainerConfigError   0          58s
api-86549f8c79-qwwld   0/1     CreateContainerConfigError   0          58s
api-86549f8c79-xlfgl   0/1     CreateContainerConfigError   0          58s

controlplane $ k get cm -n application1
NAME                 DATA   AGE
configmap-category   1      73s
kube-root-ca.crt     1      74s

controlplane $ k get po -n application1 -o yaml | grep -i configmap -C10

      state:
        waiting:
          message: configmap "category" not found

<snipped>

  spec:
    containers:
    - env:
      - name: CATEGORY
        valueFrom:
          configMapKeyRef:
            key: category
            name: category


controlplane $ k edit deployments.apps -n application1 api
