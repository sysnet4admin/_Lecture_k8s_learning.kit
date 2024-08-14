#!/usr/bin/env bash

# set variable 
NAMESPACE='default'
SERVICEACCOUNT='sa-pod-admin'
SETCRED='set-pod-admin'
SETCTXNAME='ctx-pod-admin'

# create manually token
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount
TOKENNAME='sa-pod-admin-token'
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

TOKENNAME=`kubectl -n $NAMESPACE get serviceaccount $SERVICEACCOUNT -o jsonpath={.secrets[0].name}`

# confirm token 
echo "$SERVICEACCOUNT of $NAMESPACE Token: `kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`"

# set own context 
kubectl config set-credentials $SETCRED --token=`kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`
kubectl config set-context $SETCTXNAME --cluster=kubernetes --user=$SETCRED
