#!/usr/bin/env bash

# helm add prometheus-community repo 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# actual install prometheus 
helm install prometheus prometheus-community/prometheus \
--set pushgateway.enabled=false \
--set alertmanager.enabled=false \
--set server.persistentVolume.storageClass="managed-nfs-storage" \
--set server.service.type="LoadBalancer" \
--namespace=monitoring \
--create-namespace

