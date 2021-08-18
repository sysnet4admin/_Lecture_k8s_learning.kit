#!/usr/bin/env bash

# set variable 
NAMESPACE='default'
SERVICEACCOUNT='sa-pod-admin'
SETCRED='set-pod-admin'
SETCTXNAME='ctx-pod-admin'
TOKENNAME=`kubectl -n $NAMESPACE get serviceaccount $SERVICEACCOUNT -o jsonpath={.secrets[0].name}`

# confirm token 
echo "$SERVICEACCOUNT of $NAMESPACE Token: `kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`"

# set own context 
kubectl config set-credentials $SETCRED --token=`kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`
kubectl config set-context $SETCTXNAME --cluster=kubernetes --user=$SETCRED
