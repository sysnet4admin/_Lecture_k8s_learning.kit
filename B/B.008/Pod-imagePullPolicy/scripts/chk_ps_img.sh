#!/usr/bin/env bash

HOST=$1

echo -e "\n#1 [ crictl ps on $HOST ]"
ssh root@$HOST 'crictl ps'

echo -e "\n#2 [ running containers on $HOST ]"
ssh root@$HOST ls -rlt /var/lib/containerd/io.containerd.grpc.v1.cri/containers/

echo -e "\n#3 [ downloaded images in the last 1 hour on $HOST ]"
ssh root@$HOST find /var/lib/containerd/io.containerd.content.v1.content/blobs/sha256 -type f -mmin -60

