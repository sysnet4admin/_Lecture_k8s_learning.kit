#!/usr/bin/env bash

HOST=$1
REMOTE=$(ssh root@$HOST)

echo -e "#1 [ crictl ps on $HOST ]"
$REMOTE crictl ps

echo -e "#2 [ running containers on $HOST ]"
$REMOTE ll /var/lib/containerd/io.containerd.grpc.v1.cri/containers/

echo -e "#3 [ downloaded images in the last 1 hour on $HOST ]"
$REMOTE find /var/lib/containerd/io.containerd.content.v1.content/blobs/sha256 -type f -mmin -60

