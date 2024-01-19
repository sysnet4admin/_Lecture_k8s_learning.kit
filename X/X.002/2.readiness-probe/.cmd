# Create a Deployment with a ReadinessProbe

controlplane $ k create deploy space-alien-welcome-message-generator --image=httpd:alpine -o yaml --dry-run=client > space-alien-welcome-message-generator.yaml

controlplane $ cat space-alien-welcome-message-generator.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: space-alien-welcome-message-generator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: space-alien-welcome-message-generator
  strategy: {}
  template:
    metadata:
      labels:
        app: space-alien-welcome-message-generator
    spec:
      containers:
      - image: httpd:alpine
        name: httpd
        resources: {}
        readinessProbe:
          exec:
            command:
            - stat
            - /tmp/ready
          initialDelaySeconds: 10
          periodSeconds: 5


# Make the Deployment Ready

controlplane $ k get po 
NAME                                                     READY   STATUS    RESTARTS   AGE
space-alien-welcome-message-generator-7db96b5ff6-6xjwr   0/1     Running   0          87s

controlplane $ k exec space-alien-welcome-message-generator-7db96b5ff6-6xjwr -- touch /tmp/ready 

controlplane $ k get po
NAME                                                     READY   STATUS    RESTARTS   AGE
space-alien-welcome-message-generator-7db96b5ff6-6xjwr   1/1     Running   0          3m11s
