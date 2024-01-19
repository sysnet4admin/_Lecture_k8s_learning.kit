# The Apiserver manifest contains errors

controlplane $ crictl ps -a | grep -i api
<none>

controlplane $ journalctl -u kubelet  | grep kube-apiserver
<Could not process manifest file>, <yaml: line 4: could not find expected ':'>
fixed - metadata;

controlplane $ vi /etc/kubernetes/manifests/kube-apiserver.yaml

---

controlplane $ tail -f /var/log/containers/kube-apiserver-controlplane_kube-system_kube-apiserver-93cfa763c0a92fcd3f8f6e2e1e89c75631e4cb578a81af5a8a6050f026edd4fa.log
2024-01-19T12:24:48.956235928Z stderr F Error: unknown flag: --authorization-modus
fixed - --authorization-mode 

controlplane $ vi /etc/kubernetes/manifests/kube-apiserver.yaml

---

controlplane $ crictl ps 
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
312131bfc9acd       7fe0e6f37db33       3 seconds ago       Running             kube-apiserver            1                   80b8663ec8896       kube-apiserver-controlplane
bfc55d6d2af75       d058aa5ab969c       9 minutes ago       Running             kube-controller-manager   2                   5dbd4bdaf0256       kube-controller-manager-controlplane
9d22d37883168       e3db313c6dbc0       9 minutes ago       Running             kube-scheduler            2                   b977e3c158226       kube-scheduler-controlplane
09ea75260b67d       e6ea68648f0cd       10 minutes ago      Running             kube-flannel              1                   72cb41cc9357d       canal-v2qtp
b93eac2e74a41       75392e3500e36       10 minutes ago      Running             calico-node               1                   72cb41cc9357d       canal-v2qtp
9b76bb236239d       83f6cc407eed8       10 minutes ago      Running             kube-proxy                1                   a8ce8aa44a0ab       kube-proxy-dm6fq
0addc6153cfe4       73deb9a3f7025       10 minutes ago      Running             etcd                      1                   e30e541525707       etcd-controlplane
controlplane $ crictl logs 3121
I0119 12:27:23.335656       1 options.go:220] external host was not specified, using 172.30.1.2
I0119 12:27:23.336636       1 server.go:148] Version: v1.28.4
I0119 12:27:23.336778       1 server.go:150] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0119 12:27:23.802711       1 shared_informer.go:311] Waiting for caches to sync for node_authorizer
I0119 12:27:23.804395       1 plugins.go:158] Loaded 12 mutating admission controller(s) successfully in the following order: NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,RuntimeClass,DefaultIngressClass,MutatingAdmissionWebhook.
I0119 12:27:23.804560       1 plugins.go:161] Loaded 13 validating admission controller(s) successfully in the following order: LimitRanger,ServiceAccount,PodSecurity,Priority,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,ClusterTrustBundleAttest,CertificateSubjectRestriction,ValidatingAdmissionPolicy,ValidatingAdmissionWebhook,ResourceQuota.
I0119 12:27:23.804897       1 instance.go:298] Using reconciler: lease
W0119 12:27:23.806229       1 logging.go:59] [core] [Channel #5 SubChannel #6] grpc: addrConn.createTransport failed to connect to {Addr: "127.0.0.1:23000", ServerName: "127.0.0.1", }. Err: connection error: desc = "transport: Error while dialing: dial tcp 127.0.0.1:23000: connect: connection refused"

fixed - --etcd-servers=https://127.0.0.1:2379

