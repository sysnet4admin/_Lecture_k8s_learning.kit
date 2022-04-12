#!/usr/bin/env bash
nfsdir=/nfs_shared/$1
if [[ -f /etc/redhat-release ]]; then 
  svcname=nfs 
elif [[ -f /etc/lsb-release ]]; then 
  svcname=nfs-server 
fi 

if [ $# -eq 0 ]; then
  echo "usage: nfs-exporter.sh <name>"; exit 0
fi

if [[ ! -d /nfs_shared ]]; then
  mkdir /nfs_shared
fi

if [[ ! -d $nfsdir ]]; then
  mkdir -p $nfsdir
  echo "$nfsdir 192.168.1.0/24(rw,sync,no_root_squash)" >> /etc/exports
  if [[ $(systemctl is-enabled $svcname) -eq "disabled" ]]; then
    systemctl enable $svcname
  fi
    systemctl restart $svcname 
fi

