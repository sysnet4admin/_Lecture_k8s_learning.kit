#!/usr/bin/env bash

#Read hosts from file
readarray hosts < /etc/hosts

##clear unused images at all nodes ##
for host in ${hosts[@]}; do
  ssh root@$host crictl rmi --prune
done

