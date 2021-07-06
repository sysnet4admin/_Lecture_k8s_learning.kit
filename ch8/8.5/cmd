


copy from 5.6 to here. 


[root@m-k8s 8.7]# ka LimitRange.yaml

[root@m-k8s 8.7]# k describe limitranges -n dev2
Name:                  limits-dev2
Namespace:             dev2
Type                   Resource  Min  Max  Default Request  Default Limit  Max Limit/Request Ratio
----                   --------  ---  ---  ---------------  -------------  -----------------------
PersistentVolumeClaim  storage   1Gi  2Gi  -                -              -
Container              memory    -    -    256Mi            512Mi          -




[root@m-k8s 8.7]# ka limits-1G-pvc.yaml
persistentvolumeclaim/limits-1g-pvc created
[root@m-k8s 8.7]# ka limits-3G-pvc.yaml
Error from server (Forbidden): error when creating "limits-3G-pvc.yaml": persistentvolumeclaims "limits-3g-pvc" is forbidden: maximum storage usage per PersistentVolumeClaim is 2Gi, but request is 3Gi
[root@m-k8s 8.7]# k get pvc -n dev2
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
limits-1g-pvc   Bound    pvc-c385fedc-a0be-400f-9a9a-02e3521088b5   1Gi        RWX            managed-nfs-storage   12s


[root@m-k8s 8.7]# ka limits-defaultRequest.yaml




[root@m-k8s 8.7]# k -n dev2 get pod limits-defaultrequest-5fbb49db6f-fpnxb -o yaml | grep requests -F3
    resources:
      limits:
        memory: 512Mi
      requests:
        memory: 256Mi
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File



^C[root@m-k8s 8.7]# k get po -n dev2
NAME                                     READY   STATUS    RESTARTS   AGE
limits-defaultrequest-5875949984-7kwhl   1/1     Running   0          2m27s
limits-defaultrequest-5875949984-fmfw9   1/1     Running   0          2m27s
limits-defaultrequest-5875949984-hp4ft   1/1     Running   0          2m27s
[root@m-k8s 8.7]# k -n dev2 scale deployment limits-defaultrequest --replicas=10
deployment.apps/limits-defaultrequest scaled
[root@m-k8s 8.7]# k get po -n dev2 -w
NAME                                     READY   STATUS              RESTARTS   AGE
limits-defaultrequest-5875949984-4ddrp   0/1     Pending             0          2s
limits-defaultrequest-5875949984-4zmmh   0/1     Pending             0          0s
limits-defaultrequest-5875949984-664td   0/1     OutOfmemory         0          2s
limits-defaultrequest-5875949984-6bpvz   0/1     Pending             0          1s
limits-defaultrequest-5875949984-79sx6   0/1     ContainerCreating   0          2s
limits-defaultrequest-5875949984-7kwhl   1/1     Running             0          2m47s
limits-defaultrequest-5875949984-9gxzc   0/1     ContainerCreating   0          2s
limits-defaultrequest-5875949984-9l2bt   0/1     Pending             0          1s


