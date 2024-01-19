# Create ConfigMaps

controlplane $ k create cm trauerweide --from-literal tree=trauerweide

controlplane $ k apply -f /root/cm.yaml

---
# Access ConfigMaps in Pod

controlplane $ cat pod1.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  volumes:
  - name: birke
    configMap:
      name: birke
  containers:
  - image: nginx:alpine
    name: pod1
    volumeMounts:
      - name: birke
        mountPath: /etc/birke
    env:
      - name: TREE1
        valueFrom:
          configMapKeyRef:
            name: trauerweide
            key: tree

