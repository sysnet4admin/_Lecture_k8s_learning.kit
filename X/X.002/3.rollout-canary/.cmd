# Perform a Canary rollout of an application

# 80% of requests should hit the old image
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: wonderful
  name: wonderful-v1
spec:
  replicas: 8                      <<<
  selector:
    matchLabels:
      app: wonderful
  template:
    metadata:
      labels:
        app: wonderful
    spec:
      containers:
      - image: httpd:alpine
        name: httpd

# 20% of requests should hit the new image
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: wonderful
  name: wonderful-v2                <<<
spec:
  replicas: 2                       <<<
  selector:
    matchLabels:
      app: wonderful
  template:
    metadata:
      labels:
        app: wonderful
    spec:
      containers:
      - image: nginx:alpine         <<<
        name: nginx
