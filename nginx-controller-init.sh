#!/bin/bash

#-----------------------------------------------------------------------------------
## Create and Deploy Nginx-ingress Controller (you can use built-in gce controller)

NAMESPACE_controller="nginx-system"
kubectl get ns $NAMESPACE_controller >/dev/null 2>&1 || kubectl create ns $NAMESPACE_controller
helm upgrade --install nginx-ingress "Main-Service-Ingress/nginx-ingress" \
    -n $NAMESPACE \
    -f Main-Service-Ingress/nginx-ingress/values.yaml