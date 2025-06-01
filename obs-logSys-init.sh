#!/bin/bash

# set -euo pipefail

# Setup namespace
NAMESPACE="bleh-dev"

# Ensure the namespace exists
kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

# Install Elastic CRDs
kubectl apply -f https://download.elastic.co/downloads/eck/2.12.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.12.0/operator.yaml

# Create credentials secret (idempotent creation)
kubectl create secret generic elastic-credentials \
    --namespace $NAMESPACE \
    --from-literal=elastic=changeme \
    --from-literal=kibana_system=changeme \
    --dry-run=client -o yaml | kubectl apply -f -

# Install/upgrade Elasticsearch
helm upgrade --install elasticsearch ./Observation_setup/logs_system/eck-elasticsearch \
    -n $NAMESPACE \
    -f Observation_setup/logs_system/elasticsearch-values.yml


# Install/upgrade Kibana (initial deployment with placeholder)
KIBANA_PATH="Observation_setup/logs_system/eck-kibana"
helm upgrade --install kibana "$KIBANA_PATH" \
    -n "$NAMESPACE" \
    -f Observation_setup/logs_system/kibana-values.yml

echo "⏳ Waiting for external IP..."
for i in {1..20}; do
  EXTERNAL_IP_KIBANA=$(kubectl get ingress kibana-eck-kibana -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [[ -n "$EXTERNAL_IP_KIBANA" ]]; then
    echo "🌐 Found External IP: $EXTERNAL_IP_KIBANA"
    break
  else
    echo "Still waiting... retry $i/20"
    sleep 10
  fi
done

# Ensure tmp directory exists
mkdir -p "${KIBANA_PATH}/tmp"

# Replace "0.0.0.0" with external IP in kibana-values.yml
sed "s|0.0.0.0|$EXTERNAL_IP_KIBANA|g" \
    "Observation_setup/logs_system/kibana-values.yml" > "${KIBANA_PATH}/tmp/kibana-values.yml"

# Re-deploy Kibana with updated values
helm upgrade --install kibana "$KIBANA_PATH" \
    -n "$NAMESPACE" \
    -f "${KIBANA_PATH}/tmp/kibana-values.yml"

# Install/upgrade Filebeat
kubectl apply -f Observation_setup/logs_system/filebeat-beats.yml