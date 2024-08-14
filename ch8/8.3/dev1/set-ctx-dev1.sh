#!/usr/bin/env bash

# set variable 
NAMESPACE='dev1'
SERVICEACCOUNT='dev1-hoon'
SETCRED='dev1-set-hoon'
SETCTXNAME='ctx-dev1-hoon'

# create manually token 
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount
TOKENNAME='dev1-hoon-token'
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $TOKENNAME
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: $SERVICEACCOUNT
type: kubernetes.io/service-account-token
EOF

# confirm token 
echo "$SERVICEACCOUNT of $NAMESPACE Token: `kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`"

# set own context 
kubectl config set-credentials $SETCRED --token=`kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`
kubectl config set-context $SETCTXNAME --cluster=kubernetes --user=$SETCRED
