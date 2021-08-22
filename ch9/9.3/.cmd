kubectl create secret generic mysql-cred \
  --from-literal=username='db-user' \
  --from-literal=password='hoon'
  

[root@m-k8s 8.3]# k get secrets mysql-cred -o yaml
apiVersion: v1
data:
  password: aG9vbg==
  username: ZGItdXNlcg==
kind: Secret
<snipped>

k edit secrets mysql-cred 
> easy to modify 

k delete secrets mysql-cred 

cat secrets-immutable.yaml 
ka secrets-immutable.yaml 

[root@m-k8s 9.3]# echo ZGItdXNlcg== | base64 --decode
db-user
[root@m-k8s 9.3]# echo aG9vbg== | base64 --decode
hoon




===== in MYSQL ===== 
mysql -u root -p
Enter password: MY_PASSWORD

use mysql;
SELECT user, host, plugin FROM user;
show databases;
