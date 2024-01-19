# NetworkPolicy

run before starting 
run.sh (create ns and db in sensitive ns)

root@10cka-con:~# cat deny-egress.yaml 
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-egress
  namespace: sensitive 
spec:
  podSelector: {}
  policyTypes:
  - Egress

root@10cka-con:~# cat allow-db.yaml 
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-db 
  namespace: sensitive 
spec:
  podSelector:
    matchLabels:
      role: database
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0

create net-tools in sensitivie namespace (2 types / with role whether or not)


# API Protection
root@10cka-con:~# k create sa cks-sa
serviceaccount/cks-sa created
root@10cka-con:~# cat cks-sa.yaml 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: cks-sa
  name: cks-sa
spec:
  serviceAccountName: cks-sa
  automountServiceAccountToken: false
  containers:
  - image: nginx
    name: cks-sa
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


# AppArmor

apparmor setup on bk8s-w1
root@bk8s-w1:/etc/apparmor.d# apparmor_parser deny-write 
root@bk8s-w1:/etc/apparmor.d# aa-status 

root@10cka-con:~# cat aa-sleepy.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: aa-sleepy 
  annotations:
    # Tell Kubernetes to apply the AppArmor profile "k8s-apparmor-example-deny-write".
    # Note that this is ignored if the Kubernetes node is not running version 1.4 or greater.
    container.apparmor.security.beta.kubernetes.io/aa-sleepy: localhost/deny-write
spec:
  containers:
  - name: aa-sleepy
    image: sysnet4admin/sleepy

# PodSecurityPolicy

k create sa psp-sa
serviceaccount/psp-sa created

ssh hk8s-m
vi /etc/kubernetes/manifests/kube-apiserver.yaml 
<snipped>
  - --enable-admission-plugins=NodeRestriction,PodSecurityPolicy << add PodSecurityPolicy
<snipped>

root@hk8s-m:~# cat psp-hostpath.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp-hostpath
spec:
  privileged: true  # Don't allow privileged pods!
  # The rest fills in some required fields.
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - '*'
  allowedHostPaths:
    # This allows "/foo", "/foo/", "/foo/bar" etc., but
    # disallows "/fool", "/etc/foo" etc.
    # "/foo/../" is never valid.
    - pathPrefix: "/tmp"


root@hk8s-m:~# k create clusterrole psp-r --verb=use --resource=PodSecurityPolicy
root@hk8s-m:~# k create clusterrolebinding psp-rb --clusterrole=psp-r --serviceaccount=default:psp-sa

Test >> to deploy each of deployments (hostpath-varlog.yaml and hostpath-tmp.yaml)


# ImagePolicyWebhook
run before starting 
run.sh (make admission dir and transfer files)

ssh wk8s-m
check ing ing all of files 

vi /etc/kubernetes/manifests/kube-apiserver.yaml 
<snipped>
    - --admission-control-config-file=/etc/kubernetes/admission/admission.yaml
    - --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook << add ImagePolicyWebhook
<snipped>
    - mountPath: /etc/kubernetes/admission
      name: admission
      readOnly: true
<snipped>
  - hostPath:
      path: /etc/kubernetes/admission
      type: DirectoryOrCreate
    name: admission
<snipped>

Deploy nginx for testing purpose
k run nginx --image=nginx 
Error from server (Forbidden): pods "nginx" is forbidden: Post "https://ext-svc:8080/img-validation?timeout=30s": dial tcp: lookup ext-svc on 10.0.2.3:53: no such host

# API Audit log  

searching audit policy 

ssh bk8s-m

mkdir /etc/kubernetes/audit


vi /etc/kubernetes/manifests/kube-apiserver.yaml 
<snipped>
    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml
    - --audit-log-path=/etc/kubernetes/audit/audit.log
<snipped>
    - mountPath: /etc/kubernetes/audit
      name: audit
      readOnly: true << it should remove 
<snipped>
  - hostPath:
      path: /etc/kubernetes/audit
      type: DirectoryOrCreate
    name: audit
<snipped>

root@bk8s-m:/etc/kubernetes/audit# cat policy.yaml
apiVersion: audit.k8s.io/v1 # This is required.
kind: Policy
# Don't generate audit events for all requests in RequestReceived stage.
rules:
  - level: Metadata
    resources:
    - group: ""
      resources: ["pods/log", "pods/status"]
  - level: None

root@bk8s-m:/etc/kubernetes/audit# tail audit.log
{"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"772a92e7-2261-45d5-83aa-a6a54380f8b2","stage":"RequestReceived","requestURI":"/api/v1/namespaces/kube-system/pods/kube-scheduler-bk8s-m/status","verb":"patch","user":{"username":"system:node:bk8s-m","groups":["system:nodes","system:authenticated"]},"sourceIPs":["192.168.1.110"],"userAgent":"Go-http-client/2.0","objectRef":{"resource":"pods","namespace":"kube-system","name":"kube-scheduler-bk8s-m","apiVersion":"v1","subresource":"status"},"requestReceivedTimestamp":"2022-01-10T08:08:25.214688Z","stageTimestamp":"2022-01-10T08:08:25.214688Z"}
{"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"772a92e7-2261-45d5-83aa-a6a54380f8b2","stage":"ResponseComplete","requestURI":"/api/v1/namespaces/kube-system/pods/kube-scheduler-bk8s-m/status","verb":"patch","user":{"username":"system:node:bk8s-m","groups":["system:nodes","system:authenticated"]},"sourceIPs":["192.168.1.110"],"userAgent":"Go-http-client/2.0","objectRef":{"resource":"pods","namespace":"kube-system","name":"kube-scheduler-bk8s-m","apiVersion":"v1","subresource":"status"},"responseStatus":{"metadata":{},"code":200},"requestReceivedTimestamp":"2022-01-10T08:08:25.214688Z","stageTimestamp":"2022-01-10T08:08:25.237741Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}


