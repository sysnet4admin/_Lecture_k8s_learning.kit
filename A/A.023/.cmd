cd _Lecture_k8s_learning.kit/A/A.023

# DEMO pluto
pluto

pluto detect-files
pluto detect-files -o wide 
pluto detect-files -o markdown 
pluto detect-files -o csv 

pluto detect-files -d ~/_Lecture_k8s_learning.kit/
pluto detect-files -d ~/_Lecture_k8s_learning.kit/ -o markdown

./pluto-detect-helm-sample/bad-metallb-psp-v1beta1.sh
pluto detect-helm -o markdown

# DEMO kubectl convert 

kubectl convert --help
pluto detect-files -o markdown

kubectl convert -f 

