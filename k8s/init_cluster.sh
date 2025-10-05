#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Prevents errors in a pipeline from being masked

# Variables
CLUSTER_NAME="unpaid-developers-singapore-eks-cluster"
REGION="ap-southeast-1"
NAMESPACE="istio-ingress"
SECRET_NAME="bchwey-zerossl-tls-secret"
CERT_FOLDER="certificates"
CERT_FILE="$CERT_FOLDER/tls.crt"
KEY_FILE="$CERT_FOLDER/private.key"

# Domain List
DOMAIN_LIST=(
  "bchwey.com"
  "argocd.bchwey.com"
  "kibana.bchwey.com"
  "grafana.bchwey.com"
  "jaeger.bchwey.com"
  "kiali.bchwey.com"
  "temporal.bchwey.com"
)

# Update Kubeconfig
echo "Updating kubeconfig for cluster: $CLUSTER_NAME in region: $REGION"
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

# Initial Deployment
echo "Applying namespaces..."
kubectl apply -f namespaces/ --recursive

# Try applying CRDs (idempotent)
echo "Applying ElasticSearch CRDs..."
kubectl apply -f https://download.elastic.co/downloads/eck/2.12.1/crds.yaml || {
  echo "Failed to apply CRDs. Continuing..."
}

# Apply Argo Rollouts
echo "Applying Argo Rollouts..."
kubectl create namespace argo-rollouts || echo "Namespace already exists"
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/notifications-install.yaml

# Other Initial Resources
echo "Applying initial resources..."
kubectl apply -f init_resources/ --recursive

# Configuring Secrets
echo "Applying secrets..."
kubectl apply -f secrets/ --recursive || {
  echo "Secrets folder not found or not accessible. Skipping secrets configuration."
}

# SSL Certificate Integration Using ZeroSSL Multi-Domain Certificate
integrate_certificate() {
  set -e  # Exit the function if any command fails

  echo "Integrating ZeroSSL multi-domain certificate..."

  # Ensure the certificate files exist
  if [[ ! -f "$CERT_FOLDER/certificate.crt" || ! -f "$CERT_FOLDER/ca_bundle.crt" || ! -f "$KEY_FILE" ]]; then
    echo "Certificate files not found in $CERT_FOLDER. Please ensure certificate.crt, ca_bundle.crt, and private.key are present."
    break # exits the do block but continues the script
  fi

  # Combine the certificate and CA bundle
  cat "$CERT_FOLDER/certificate.crt" "$CERT_FOLDER/ca_bundle.crt" > "$CERT_FILE"

  # Ensure the namespace exists (idempotent)
  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace $NAMESPACE already exists"
  else
    echo "Creating namespace $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
  fi

  # Create or update Kubernetes TLS secret (idempotent)
  echo "Creating or updating Kubernetes TLS secret: $SECRET_NAME"
  kubectl create secret tls "$SECRET_NAME" \
    --cert="$CERT_FILE" \
    --key="$KEY_FILE" \
    --namespace="$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -

  echo "ZeroSSL multi-domain certificate integrated."
}

# Try to run the certificate integration
if ! integrate_certificate; then
  echo "Certificate integration failed. Skipping this block."
fi

# Configure Networking
echo "Applying networking configuration..."
kubectl apply -f networking/ --recursive

# Redeploy Argo Notification Controller to mount config map (added from init_resources)
kubectl rollout restart deployment/argocd-notifications-controller -n argocd

echo "Cluster initialization complete."
