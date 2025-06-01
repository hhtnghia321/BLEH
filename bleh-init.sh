#!/bin/bash

# Create Namespace
kubectl create ns nginx-system
kubectl create ns bleh-dev

# Initial GCP and build Application Image
. gcloud-init.sh

# Deploy Nginx Controller
. nginx-controller-init.sh

# Deploy Application to GKE (Only Application with Ingress from Controller)
. main-service-ingress-init.sh

# Deploy Logs Stack ELK
. obs-logSys-init.sh