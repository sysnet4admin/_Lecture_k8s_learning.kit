# B.13.003-2.Implemeting the Adapter Pattern

k run adapter --image=busybox -o yaml --dry-run -- /bin/sh -c 'while true; do echo "$(date) | $(du -sh ~)" >> /var/logs/diskspace.txt; sleep 5; done;' > adapter.yaml

made yaml and modify it 
 
root@10cka-con:~# cat adapter.yaml 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: adapter
  name: adapter
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - while true; do echo "$(date) | $(du -sh ~)" >> /var/logs/diskspace.txt; sleep
      5; done;
    image: busybox
    name: app
    volumeMounts:
      - name: config-volume
        mountPath: /var/logs

  - image: busybox
    name: transformer
    args:
    - /bin/sh
    - -c
    - 'sleep 20; while true; do while read LINE; do echo "$LINE" | cut -f2 -d"|" >> $(date +%Y-%m-%d-%H-%M-%S)-transformed.txt; done < /var/logs/diskspace.txt; sleep 20; done;'
    volumeMounts:
      - name: config-volume
        mountPath: /var/logs

  volumes:
    - name: config-volume
      emptyDir: {}
    
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


k exec adapter -c transformer -it -- /bin/sh


# 2 B.13.003-3.Routing Traffic to Pods from Inside and Outside of a Cluster
k create deploy myapp --image=nginx --port=80 --dry-run -o yaml > myapp.yaml

And change replicas from 1 to 2 

apply 

k expose deployment myapp --port=80

k exec busybox -it -- /bin/sh 
wget clusterIP -O cl.index 

k edit svc myapp
wget 192.168.1.111:31292 -O np.index


# 3 B.13.003-4.Defining a Pod's Readiness and Liveness Probe
k run hello --image=bonomat/nodejs-hello-world --port=3000 -o yaml --dry-run > hello.yaml
hello.yaml 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: hello
  name: hello
spec:
  containers:
  - image: bonomat/nodejs-hello-world
    name: hello
    ports:
    - name: nodejs-port
      containerPort: 3000
    readinessProbe:
      httpGet:
        path: /
        port: nodejs-port
      initialDelaySeconds: 2
    livenessProbe:
      httpGet:
        path: /
        port: nodejs-port
      initialDelaySeconds: 5
      periodSeconds: 8
    ports:
    - containerPort: 3000
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


kubectl exec hello -it -- /bin/sh
# curl localhost:3000

root@10cka-con:~# k logs hello 
Magic happens on port 3000


4 B.13.003-5.Configuring a Pod to Use a ConfigMap
It already in the directory 4
B/4/config.txt
DB_URL=localhost:3306
DB_USERNAME=postgres

k create cm db-config --from-env-file=config.txt
k run backend --image=nginx --dry-run -o yaml > backend.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: backend
  name: backend
spec:
  containers:
  - image: nginx
    name: backend
    envFrom:
      - configMapRef:
          name: db-config
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


5 X.13.002-6.Creating a Scheduled Container Operation

[root@m-k8s ~]# cat cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: current-date
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: nginx
            command:
            - /bin/sh
            - -c
            - 'echo "Current date: $(date)"'
          restartPolicy: OnFailure

[root@m-k8s ~]# k get cronjobs.batch current-date -o yaml | grep -i history
  failedJobsHistoryLimit: 1
  successfulJobsHistoryLimit: 3

