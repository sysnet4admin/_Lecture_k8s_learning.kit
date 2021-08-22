k apply -f deploy-rollout.yaml --record
k rollout history deployment deploy-rollout
k get pods | grep image 
k get pods -o yaml
curl -I --silent 172.16.103.143 | grep Server

k set image deployment deploy-rollout nginx=nginx:1.21.0 --record
k get pods 
k rollout status deployment deploy-rollout
k rollout history deployment deploy-rollout
curl -I --silent 172.16.132.10 | grep Server

k set image deployment deploy-rollout nginx=nginx:1.21.21 --record
k get pods 
k rollout status deployment deploy-rollout

k describe deployment deploy-rollout
k rollout history deployment deploy-rollout
k rollout undo deployment deploy-rollout
k get pods 
k rollout history deployment deploy-rollout
curl -I --silent 172.16.132.10 | grep Server

k rollout status deployment deploy-rollout
k describe deployment deploy-rollout
k rollout undo deployment deploy-rollout --to-revision=1
k get pods 

curl -I --silent 172.16.103.150 | grep Server

