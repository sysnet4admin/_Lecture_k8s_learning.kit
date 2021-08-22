[root@m-k8s ~]# k get po -n kubernetes-dashboard
NAME                                         READY   STATUS    RESTARTS      AGE
dashboard-metrics-scraper-66fd8f6556-7h2q8   1/1     Running   0             87s
kubernetes-dashboard-659c47875d-xn78k        1/1     Running   1 (27s ago)   87s
[root@m-k8s ~]# k get svc -n kubernetes-dashboard
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
dashboard-metrics-scraper   ClusterIP      10.110.230.59   <none>         8000/TCP       93s
kubernetes-dashboard        LoadBalancer   10.102.249.22   192.168.1.15   80:30959/TCP   93

===
overview 모두 확인 
deployment 배포 (service 포함)
deployment로 배포된 pod exec 접속 
deployment scale 3 그리고 확인 
deployment 삭제 확인 그리고 확인  
함께 배포된 service 삭제 그리고 확인 