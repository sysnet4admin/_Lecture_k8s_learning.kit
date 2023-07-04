#!/usr/bin/env bash

if [ ! -z $1 ] 
then 
  for (( c=1; c<=$1; c++ ))
    do 
      kubectl label node w$c-k8s gpupool=Nvidia accelerator=Tesla-H100
    done 
    : # $1 was given
else
    echo "Input labeling node number"
    : # $1 was not given
fi

