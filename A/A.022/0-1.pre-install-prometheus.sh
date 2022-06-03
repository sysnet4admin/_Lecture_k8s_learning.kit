#!/usr/bin/env bash

# helm add edu repo 
helm repo add edu https://prometheus-community.github.io/helm-charts
helm repo update

# actual install prometheus 
helm install prometheus edu/prometheus \
--set pushgateway.enabled=false \
--set alertmanager.enabled=false \
--set nodeExporter.tolerations[0].key="node-role.kubernetes.io/master" \
--set nodeExporter.tolerations[0].effect="NoSchedule" \
--set nodeExporter.tolerations[0].operator="Exists" \
--set server.persistentVolume.storageClass="managed-nfs-storage" \
--set server.service.type="LoadBalancer" \
--namespace=monitoring \
--create-namespace

