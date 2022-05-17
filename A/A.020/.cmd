# like bastion or vpn 

./2.telepresence-2.5.8-installer.sh

telepresence version 
telepresence status 
telepresence connect 
telepresence list 

kubectl run chk-ip --image=sysnet4admin/chk-ip 
kubectl expose chk-ip --port=80
telepresence list 

curl chk-ip.default 

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
