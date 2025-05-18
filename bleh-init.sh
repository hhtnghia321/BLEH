#!/bin/bash

# Initial GCP and build Application Image
. gcloud-init.sh

# Deploy Application to GKE (will deploy both Application and Controller)
. k8s-init.sh