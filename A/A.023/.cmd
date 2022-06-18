cd _Lecture_k8s_learning.kit/A/A.023

# DEMO pluto
./pluto-v5.8.0-installer.sh
pluto 
pluto list-versions 

pluto detect-files
pluto detect-files -o wide 
pluto detect-files -o markdown 
pluto detect-files -o csv 

pluto detect-files -d ~/_Lecture_k8s_learning.kit/
pluto detect-files -d ~/_Lecture_k8s_learning.kit/ -o markdown

pluto detect-files --target-versions k8s=v1.18.0 -o markdown 
pluto detect-files --target-versions k8s=v1.22.1 -o markdown 

kubectl get all -A -o yaml > /tmp/all.yaml
pluto detect-files -d /tmp/all.yaml

./pluto-detect-helm-sample/metallb-uninstaller.sh 
./pluto-detect-helm-sample/bad-metallb-psp-v1beta1.sh
pluto detect-helm -o markdown

git clone https://github.com/IaC-Source/helm-charts.git
helm template helm-charts/metallb/ | pluto detect -


# DEMO kubectl convert 
./kubectl-convert-installer.sh
kubectl convert --help
pluto detect-files -o markdown

# good
cat kubectl-convert-sample/good-deploy-svc-nginx-v1beta2.yaml
kubectl apply -f  kubectl-convert-sample/good-deploy-svc-nginx-v1beta2.yaml
kubectl delete -f  kubectl-convert-sample/good-deploy-svc-nginx-v1beta2.yaml

kubectl convert -f kubectl-convert-sample/good-deploy-svc-nginx-v1beta2.yaml
kubectl convert -f kubectl-convert-sample/good-deploy-svc-nginx-v1beta2.yaml | kubectl apply -f -

# bad1
kubectl convert -f kubectl-convert-sample/bad-ingress-v1beat1.yaml
cat kubectl-convert-sample/bad-ingress-v1beat1.yaml

# bad2
kubectl convert -f kubectl-convert-sample/bad-hpa-custom-metrics-v2beta1.yaml
kubectl convert -f kubectl-convert-sample/bad-hpa-custom-metrics-v2beta1.yaml --output-version autoscaling/v2

