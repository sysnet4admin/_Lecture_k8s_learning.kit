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



# API Audit log  
