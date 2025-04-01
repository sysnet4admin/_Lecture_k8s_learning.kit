#!/usr/bin/env bash

HOST=$1

echo -e "\n#1 [ crictl ps on $HOST ]"
ssh root@$HOST 'crictl ps'

echo -e "\n#2 [ running containers on $HOST ]"
echo -e "\nlocation: /var/lib/containerd/io.containerd.grpc.v1.cri/containers"
ssh root@$HOST ls -rlt /var/lib/containerd/io.containerd.grpc.v1.cri/containers/ | tail -n +2

echo -e "\n#3 [ downloaded images in the last 10 mintues on $HOST ]"
echo -e "\nlocation: /var/lib/containerd/io.containerd.content.v1.content/blobs/sha256"
#ssh root@$HOST find /var/lib/containerd/io.containerd.content.v1.content/blobs/sha256 -type f -mmin -60
# example: 1 hour ago, 2 hours ago, 1 day ago 
ssh root@$HOST ls -lt /var/lib/containerd/io.containerd.content.v1.content/blobs/sha256/ | awk -v threshold="$(date -d "10 minutes ago" "+%s")" '{cmd="date -d \""$6" "$7" "$8"\" +%s 2>/dev/null"; cmd | getline timestamp; close(cmd); if(timestamp >= threshold) print $0}'
