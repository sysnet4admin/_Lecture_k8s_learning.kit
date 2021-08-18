#!/usr/bin/env bash

# set variable 
NAMESPACE='dev1'
SERVICEACCOUNT='dev1-hoon'
SETCRED='dev1-set-hoon'
SETCTXNAME='ctx-dev1-hoon'
TOKENNAME=`kubectl -n $NAMESPACE get serviceaccount $SERVICEACCOUNT -o jsonpath={.secrets[0].name}`

# confirm token 
echo "$SERVICEACCOUNT of $NAMESPACE Token: `kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`"

# set own context 
kubectl config set-credentials $SETCRED --token=`kubectl -n $NAMESPACE get secret $TOKENNAME -o jsonpath={.data.token}| base64 --decode`
kubectl config set-context $SETCTXNAME --cluster=kubernetes --user=$SETCRED
