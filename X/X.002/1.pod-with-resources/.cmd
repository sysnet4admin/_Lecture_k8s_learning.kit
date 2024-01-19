# Create a Pod with Resource Requests and Limits

controlplane $ k create ns limit

controlplane $ k -n limit run resource-checker --image=httpd:alpine -o yaml --dry-run=client > resource-checker.yaml

controlplane $ cat resource-checker.yaml 
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: resource-checker
  name: resource-checker
  namespace: limit
spec:
  containers:
  - image: httpd:alpine
    name: my-container
    resources:
      requests:
        memory: "30Mi"
        cpu: "30m"
      limits:
        memory: "30Mi"
        cpu: "300m"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
