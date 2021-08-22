수행순서 

livenessprobe
readinessProbe-exec-periodSeconds5-w-lb
배포 이후 k exec readiness-exec -it -- /bin/bash 로 들어가서 
rm /tmp/healthy-on을 수행 후에 k get svc 및 k get ep확인 


watch "kubectl describe pod livenessprobe-exec | tail"
