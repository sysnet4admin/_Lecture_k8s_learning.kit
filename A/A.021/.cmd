# install console-k8s (192.168.1.241)
vagrant up console-k8s

# like bastion or vpn 

./2.telepresence-2.6.6-installer.sh

telepresence version 
telepresence status 
telepresence connect 
telepresence list 

kubectl create deploy chk-ip --image=sysnet4admin/chk-ip 
kubectl expose deploy chk-ip --port=80
telepresence list 

curl chk-ip.default 

kubectl create deploy ssh --image=sysnet4admin/ssh 
kubectl expose deploy ssh --port=22 
ssh hoon@ssh.default 

# local dev enviroment 
# if 'fresh' is not working on properly, run 'go build main.go && ./main'
./3.golang-n-sources-installer.sh

# open new terminal 
telepresence intercept dataprocessingservice --port 3000
....wait for seconds 
curl dataprocessingservice:3000/color
curl localhost:3000/color 

vi edgey-corp-go/DataProcessingService/main.go
# change var color string from blue to orange 

curl dataprocessingservice:3000/color
curl localhost:3000/color 

telepresence status
helm uninstall traffic-manager -n ambassador
telepresence quit
telepresence status 
telepresence uninstall --everything
telepresence status 
