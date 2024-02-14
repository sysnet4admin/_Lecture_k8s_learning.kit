
# check installed version 
k8sgpt version

# basic 
k8sgpt --help 
k8sgpt analyze 
k8sgpt analyze --explain # error 

# set auth after generating api-key 
[root@cp-k8s B.004]# k8sgpt generate
Please open: https://beta.openai.com/account/api-keys to generate a key for openai
Please copy the generated key and run `k8sgpt auth add` to add it to your config file

[root@cp-k8s B.004]# k8sgpt auth add
Warning: backend input is empty, will use the default value: openai
Warning: model input is empty, will use the default value: gpt-3.5-turbo
Enter openai Key: openai added to the AI backend provider list

# run again 
k8sgpt analyze --explain

# analyzing test 

## analyze missing deployment 

### run 
k8sgpt analyze 
### deploy deploy+loadbalancer
k apply -f ch4/4.4/loadbalancer-11.yaml
### delete lb 
k delete deploy deploy-nginx
### run again 
k8sgpt analyze 

## analyze missing configmap 

### deploy deploy+configmap  
k apply -f ch9/9.2/deploy-configMapRef.yaml
k apply -f ch9/9.2/ConfigMap-sleepy-config.yaml
### delete configmap 
k delete cm sleepy-config 
### run 
k8sgpt analyze 

# change AI Provider 
https://docs.k8sgpt.ai/reference/providers/backend/#google-gemini
> https://makersuite.google.com/app/apikey?hl=ko
k8sgpt auth add --backend google --model gemini-pro --password "<Your API KEY>"

# run by google 
k8sgpt analyze --explain --backend google

# run by google as default 
k8sgpt auth default -p google 
k8sgpt analyze --explain

# Support Korean 
[root@cp-k8s B.004]# k8sgpt analyze -l Korean -e
 100% |█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| (1/1, 23 it/min)        
AI Provider: google

0 default/nginx-1(nginx-1)
- Error: Service has no endpoints, expected label run=nginx-1
Error: 서비스에 엔드포인트가 없으며 run=nginx-1 레이블이 필요합니다.

해결책:
1. nginx-1 포드가 실행 중인지 확인합니다.
2. nginx-1 포드에 run=nginx-1 레이블이 있는지 확인합니다.
3. 서비스가 nginx-1 포드를 선택하고 있는지 확인합니다.

# --interactive mode 
k8sgpt analyze -l Korean -e -i
k8sgpt analyze -e -i

