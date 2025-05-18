#!/bin/bash

#-----------------------------------------------------------------------------------
## Create and Deploy Nginx-ingress Controller (you can use built-in gce controller)
cd k8s/nginx-ingress
NAMESPACE_controller="nginx-system"
kubectl get ns $NAMESPACE_controller >/dev/null 2>&1 || kubectl create ns $NAMESPACE_controller
helm upgrade --install nginx-ingress -n $NAMESPACE_controller .
cd /home/ubuntu/BLEH

# set -e  # Exit if any command fails
#-----------------------------------------------------------------------------------
NAMESPACE="bleh-dev"
RELEASE_NAME="bleh"
CHART_PATH="./"
cd k8s/BLEH

# 1. Create namespace if not exists
kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create ns $NAMESPACE

# 2. Recreate values file from env variables
mkdir -p tmp
cp values.yml tmp/values-bleh.yml
# chmod 644 tmp/values-bleh.yml
sed "s|\${IMAGE_PATH}|$IMAGE_PATH|g" tmp/values-bleh.yml > tmp/tmp.yml && mv tmp/tmp.yml tmp/values-bleh.yml
sed "s|\${IMAGE_TAG}|$IMAGE_TAG|g" tmp/values-bleh.yml > tmp/tmp.yml && mv tmp/tmp.yml tmp/values-bleh.yml
sed "s|\${NAMESPACE}|$NAMESPACE|g" tmp/values-bleh.yml > tmp/tmp.yml && mv tmp/tmp.yml tmp/values-bleh.yml
sed "s|\${EXTERNAL_IP}|0.0.0.0|g" tmp/values-bleh.yml > tmp/tmp.yml && mv tmp/tmp.yml tmp/values-bleh.yml

# 3. Initial Helm install with placeholder IP
echo "🚀 Deploying with placeholder EXTERNAL_IP..."
helm upgrade --install $RELEASE_NAME $CHART_PATH -n $NAMESPACE -f tmp/values-bleh.yml

# 4. Wait for Ingress external IP
echo "⏳ Waiting for external IP..."
for i in {1..20}; do
  EXTERNAL_IP=$(kubectl get ingress -n $NAMESPACE -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')
  if [[ -n "$EXTERNAL_IP" ]]; then
    echo "🌐 Found External IP: $EXTERNAL_IP"
    break
  else
    echo "Still waiting... retry $i/20"
    sleep 10
  fi
done

if [[ -z "$EXTERNAL_IP" ]]; then
  echo "❌ Failed to obtain external IP. Exiting."
  exit 1
fi

# 5. Inject actual EXTERNAL_IP into values file
echo "✍️ Injecting external IP into values-bleh.yml..."
sed "s|\0.0.0.0|$EXTERNAL_IP|g" tmp/values-bleh.yml > tmp/tmp.yml && mv tmp/tmp.yml tmp/values-bleh.yml

# 6. Helm upgrade with actual IP
echo "🔁 Upgrading Helm release with real EXTERNAL_IP..."
helm upgrade $RELEASE_NAME $CHART_PATH -n $NAMESPACE -f tmp/values-bleh.yml

echo "✅ Deployment complete."
echo "🌍 Access the app at: http://${EXTERNAL_IP}.nip.io"

cd /home/ubuntu/BLEH

