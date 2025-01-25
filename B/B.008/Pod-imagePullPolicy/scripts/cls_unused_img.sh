#!/usr/bin/env bash

#Read hosts from file
readarray hosts < /etc/hosts

##clear unused images at all nodes ##
for host in ${hosts[@]}; do
  sshpass -p vagrant crictl rmi --prune -f ${host}
done

