#!/usr/bin/env bash

if [ ! -z $1 ] 
then 
  for (( c=1; c<=$1; c++ ))
    do 
      kubectl taint node w$c-k8s kwok-controller/provider=test:NoSchedule-
    done 
    : # $1 was given
else
    echo "Input untainting node number"
    : # $1 was not given
fi


