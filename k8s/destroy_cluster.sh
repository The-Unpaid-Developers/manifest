#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Prevents errors in a pipeline from being masked

# Variables
CLUSTER_NAME="unpaid-developers-singapore-eks-cluster"
REGION="ap-southeast-1"
NAMESPACE="istio-ingress"
SECRET_NAME="bchwey-zerossl-tls-secret"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function for coloured output
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Update Kubeconfig
log_info "Updating kubeconfig for cluster: $CLUSTER_NAME in region: $REGION"
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

# Confirmation prompt
echo ""
echo "=========================================="
echo "CLUSTER CLEANUP SCRIPT"
echo "=========================================="
echo "This script will delete the following:"
echo "  - Admission webhooks (including Kyverno)"
echo "  - Kyverno resources (deployments, pods, services, policies, jobs, Helm state)"
echo "  - ArgoCD Applications (application workloads)"
echo "  - Init resources (monitoring, logging, operations)"
echo "  - Networking configuration"
echo "  - Secrets"
echo "  - Argo Rollouts"
echo "  - TLS certificates"
echo ""
log_warn "This script will NOT delete:"
echo "  - Helm releases (managed by Terraform)"
echo "  - CRDs (to avoid breaking existing resources)"
echo "  - Namespaces (managed by Terraform)"
echo ""
read -p "Are you sure you want to proceed? (yes/no): " confirmation

if [[ "$confirmation" != "yes" ]]; then
  log_warn "Cleanup cancelled by user."
  exit 0
fi

echo ""
log_info "Starting cluster cleanup..."

# ==============================================================================
# STEP 1: Delete Admission Webhooks First (Prevent Deadlock)
# ==============================================================================
log_info "Step 1: Removing admission webhooks to prevent deletion deadlock..."

delete_webhooks() {
  local webhook_type=$1
  local webhooks=$(kubectl get "$webhook_type" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
  
  if [[ -n "$webhooks" ]]; then
    for webhook in $webhooks; do
      # Skip Istio and EKS webhooks (managed by Terraform/AWS)
      if [[ "$webhook" =~ ^(istio|istiod|eks) ]]; then
        log_warn "  Skipping Terraform-managed webhook: $webhook"
        continue
      fi
      
      log_info "  Deleting $webhook_type: $webhook"
      kubectl delete "$webhook_type" "$webhook" --ignore-not-found=true 2>/dev/null || \
        log_warn "  Failed to delete $webhook (may already be deleted)"
    done
  else
    log_info "  No $webhook_type found"
  fi
}

log_info "Checking for validating webhooks..."
delete_webhooks "validatingwebhookconfigurations"

log_info "Checking for mutating webhooks..."
delete_webhooks "mutatingwebhookconfigurations"

# ==============================================================================
# STEP 1.5: Force Delete Kyverno Resources (Prevent Helm Uninstall Deadlock)
# ==============================================================================
log_info "Step 1.5: Force cleaning up Kyverno resources..."

# Delete Kyverno-specific webhooks (these are the main blockers)
log_info "  Deleting Kyverno webhooks..."
kubectl delete validatingwebhookconfigurations kyverno-resource-validating-webhook-cfg --ignore-not-found=true 2>/dev/null || true
kubectl delete validatingwebhookconfigurations kyverno-policy-validating-webhook-cfg --ignore-not-found=true 2>/dev/null || true
kubectl delete mutatingwebhookconfigurations kyverno-resource-mutating-webhook-cfg --ignore-not-found=true 2>/dev/null || true
kubectl delete mutatingwebhookconfigurations kyverno-policy-mutating-webhook-cfg --ignore-not-found=true 2>/dev/null || true
kubectl delete mutatingwebhookconfigurations kyverno-verify-mutating-webhook-cfg --ignore-not-found=true 2>/dev/null || true

# Delete by label (catches any remaining Kyverno webhooks)
log_info "  Deleting Kyverno webhooks by label..."
kubectl delete validatingwebhookconfigurations -l app.kubernetes.io/instance=unpaid-developers-singapore-kyverno-release --ignore-not-found=true 2>/dev/null || true
kubectl delete mutatingwebhookconfigurations -l app.kubernetes.io/instance=unpaid-developers-singapore-kyverno-release --ignore-not-found=true 2>/dev/null || true

# Delete all Kyverno policies (these can also block deletion)
log_info "  Deleting Kyverno policies..."
kubectl delete clusterpolicies --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || \
  log_warn "  No ClusterPolicies found or already deleted"

kubectl delete policies --all -A --force --grace-period=0 --ignore-not-found=true 2>/dev/null || \
  log_warn "  No Policies found or already deleted"

# Delete ClusterPolicyReports and PolicyReports
log_info "  Deleting Kyverno policy reports..."
kubectl delete clusterpolicyreports --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
kubectl delete policyreports --all -A --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true

# Remove finalizers from stuck Kyverno resources
if kubectl get namespace kyverno &>/dev/null; then
  log_info "  Checking for stuck Kyverno resources..."
  
  # Remove finalizers from stuck policies
  for policy in $(kubectl get clusterpolicies -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
    log_warn "  Removing finalizers from ClusterPolicy: $policy"
    kubectl patch clusterpolicy "$policy" -p '{"metadata":{"finalizers":null}}' --type=merge 2>/dev/null || true
  done
  
  # Force delete Kyverno deployments (prevents pod recreation)
  log_info "  Force deleting Kyverno deployments..."
  kubectl delete deployment -n kyverno --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
  
  # Force delete Kyverno replicasets
  log_info "  Force deleting Kyverno replicasets..."
  kubectl delete replicaset -n kyverno --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
  
  # Force delete Kyverno jobs (Helm cleanup jobs can get stuck)
  log_info "  Force deleting Kyverno jobs..."
  kubectl delete job -n kyverno --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
  
  # Force delete Kyverno pods if they're stuck
  log_info "  Force deleting any stuck Kyverno pods..."
  kubectl delete pods -n kyverno --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
  
  # Force delete Kyverno services
  log_info "  Force deleting Kyverno services..."
  kubectl delete svc -n kyverno --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
  
  # Clean up stuck Helm release state (secrets)
  log_info "  Cleaning up Helm release state..."
  kubectl delete secrets -n kyverno -l "name=unpaid-developers-singapore-kyverno-release,owner=helm" --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
  
  # Check if namespace is stuck in Terminating state
  if kubectl get namespace kyverno -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Terminating"; then
    log_warn "  Kyverno namespace is stuck in Terminating, removing finalizers..."
    kubectl get namespace kyverno -o json | \
      jq '.spec.finalizers = []' | \
      kubectl replace --raw /api/v1/namespaces/kyverno/finalize -f - 2>/dev/null || \
      log_warn "  Failed to remove namespace finalizers (jq may not be installed)"
  fi
fi

log_info "  Kyverno cleanup complete"

# ==============================================================================
# STEP 2: Delete ArgoCD Applications (This deletes actual workloads)
# ==============================================================================
log_info "Step 2: Deleting ArgoCD Applications..."

ARGOCD_APPS=(
  "chatbot-service"
  "core-service"
  "diagram-service"
  "frontend"
  "proxy-service"
  "kyverno-policies"
)

for app in "${ARGOCD_APPS[@]}"; do
  log_info "  Deleting ArgoCD Application: $app"
  kubectl delete application "$app" -n argocd --ignore-not-found=true --wait=false 2>/dev/null || \
    log_warn "  Application $app not found or already deleted"
done

log_info "Waiting for ArgoCD to clean up application resources (30s)..."
sleep 30

# Force delete any stuck ArgoCD application finalizers
log_info "Checking for stuck ArgoCD applications..."
for app in "${ARGOCD_APPS[@]}"; do
  if kubectl get application "$app" -n argocd &>/dev/null; then
    log_warn "  Application $app is stuck, removing finalizers..."
    kubectl patch application "$app" -n argocd -p '{"metadata":{"finalizers":null}}' --type=merge 2>/dev/null || true
  fi
done

# ==============================================================================
# STEP 3: Force Delete Application Workloads (if ArgoCD didn't clean up)
# ==============================================================================
log_info "Step 3: Cleaning up application workloads..."

SERVICES=("chatbot-service" "core-service" "diagram-service" "frontend" "proxy-service")

for service in "${SERVICES[@]}"; do
  log_info "  Force deleting workloads for: $service"
  
  # Delete rollouts
  kubectl delete rollout "$service" -n application --ignore-not-found=true --force --grace-period=0 2>/dev/null || true
  
  # Delete HPAs
  kubectl delete hpa "$service" -n application --ignore-not-found=true --force --grace-period=0 2>/dev/null || true
  
  # Delete services
  kubectl delete service "$service" -n application --ignore-not-found=true --force --grace-period=0 2>/dev/null || true
  
  # Delete any remaining pods
  kubectl delete pods -n application -l "app=$service" --ignore-not-found=true --force --grace-period=0 2>/dev/null || true
done

# ==============================================================================
# STEP 4: Delete Init Resources (Operations)
# ==============================================================================
log_info "Step 4: Deleting operations resources (ArgoCD configurations, Karpenter)..."

if [[ -d "init_resources/operations" ]]; then
  # Delete in reverse dependency order
  log_info "  Deleting Karpenter provisioners..."
  kubectl delete -f init_resources/operations/karpenter/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete Karpenter resources"
  
  log_info "  Deleting ArgoCD application manifests..."
  kubectl delete -f init_resources/operations/argocd/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete ArgoCD resources"
else
  log_warn "  Operations directory not found, skipping..."
fi

# ==============================================================================
# STEP 5: Delete Init Resources (Monitoring)
# ==============================================================================
log_info "Step 5: Deleting monitoring resources (Grafana, Kiali, Prometheus)..."

if [[ -d "init_resources/monitoring" ]]; then
  kubectl delete -f init_resources/monitoring/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete monitoring resources"
else
  log_warn "  Monitoring directory not found, skipping..."
fi

# ==============================================================================
# STEP 6: Delete Init Resources (Logging)
# ==============================================================================
log_info "Step 6: Deleting logging resources (ElasticSearch, Kibana, Fluentd)..."

if [[ -d "init_resources/logging" ]]; then
  log_info "  Deleting Fluentd DaemonSet..."
  kubectl delete -f init_resources/logging/fluentd/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete Fluentd"
  
  log_info "  Deleting ElasticSearch and Kibana..."
  kubectl delete -f init_resources/logging/eck/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete ECK resources"
  
  # Force delete any stuck Elasticsearch pods
  log_info "  Force deleting any stuck Elasticsearch pods..."
  kubectl delete pods -n logging -l "elasticsearch.k8s.elastic.co/cluster-name" --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
else
  log_warn "  Logging directory not found, skipping..."
fi

# ==============================================================================
# STEP 7: Delete Init Resources (Storage)
# ==============================================================================
log_info "Step 7: Deleting storage resources..."

if [[ -d "init_resources/storage" ]]; then
  kubectl delete -f init_resources/storage/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete storage resources"
else
  log_warn "  Storage directory not found, skipping..."
fi

# ==============================================================================
# STEP 8: Delete Networking Configuration
# ==============================================================================
log_info "Step 8: Deleting networking configuration..."

if [[ -d "networking" ]]; then
  kubectl delete -f networking/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete networking resources"
else
  log_warn "  Networking directory not found, skipping..."
fi

# ==============================================================================
# STEP 9: Delete TLS Secret
# ==============================================================================
log_info "Step 9: Deleting TLS secret..."

kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" --ignore-not-found=true 2>/dev/null && \
  log_info "  TLS secret deleted" || \
  log_warn "  TLS secret not found or already deleted"

# ==============================================================================
# STEP 10: Delete Secrets
# ==============================================================================
log_info "Step 10: Deleting secrets..."

if [[ -d "secrets" ]]; then
  kubectl delete -f secrets/ --recursive --ignore-not-found=true 2>/dev/null || \
    log_warn "  Failed to delete secrets"
else
  log_warn "  Secrets directory not found, skipping..."
fi

# ==============================================================================
# STEP 11: Delete Argo Rollouts
# ==============================================================================
log_info "Step 11: Deleting Argo Rollouts..."

log_info "  Removing Argo Rollouts notifications..."
kubectl delete -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/notifications-install.yaml --ignore-not-found=true 2>/dev/null || \
  log_warn "  Failed to delete Argo Rollouts notifications"

log_info "  Removing Argo Rollouts installation..."
kubectl delete -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml --ignore-not-found=true 2>/dev/null || \
  log_warn "  Failed to delete Argo Rollouts"

log_info "  Deleting argo-rollouts namespace..."
kubectl delete namespace argo-rollouts --ignore-not-found=true --timeout=60s 2>/dev/null || \
  log_warn "  Namespace deletion timed out or already deleted"

# ==============================================================================
# STEP 12: Clean Up Stuck Resources
# ==============================================================================
log_info "Step 12: Cleaning up any stuck resources..."

clean_stuck_resources() {
  local namespace=$1
  log_info "  Checking namespace: $namespace"
  
  # Force delete terminating pods
  local terminating_pods=$(kubectl get pods -n "$namespace" --field-selector=status.phase=Terminating -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
  if [[ -n "$terminating_pods" ]]; then
    log_warn "  Found stuck terminating pods, force deleting..."
    for pod in $terminating_pods; do
      kubectl delete pod "$pod" -n "$namespace" --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
    done
  fi
  
  # Delete stuck helm hook jobs
  local stuck_jobs=$(kubectl get jobs -n "$namespace" -o jsonpath='{.items[?(@.metadata.annotations.helm\.sh/hook)].metadata.name}' 2>/dev/null || echo "")
  if [[ -n "$stuck_jobs" ]]; then
    log_warn "  Found stuck Helm hook jobs, force deleting..."
    for job in $stuck_jobs; do
      kubectl delete job "$job" -n "$namespace" --force --grace-period=0 --ignore-not-found=true 2>/dev/null || true
    done
  fi
}

# Clean up known namespaces
for ns in application logging argo-rollouts argocd; do
  if kubectl get namespace "$ns" &>/dev/null; then
    clean_stuck_resources "$ns"
  fi
done

# ==============================================================================
# STEP 13: Final Status Check
# ==============================================================================
log_info "Step 13: Final status check..."

echo ""
echo "=========================================="
echo "CLEANUP SUMMARY"
echo "=========================================="

log_info "Resources remaining in key namespaces:"

for ns in application logging argo-rollouts; do
  if kubectl get namespace "$ns" &>/dev/null; then
    count=$(kubectl get all -n "$ns" 2>/dev/null | grep -v "^NAME" | wc -l)
    if [[ $count -gt 0 ]]; then
      log_warn "  $ns: $count resources remaining"
    else
      log_info "  $ns: Clean ✓"
    fi
  else
    log_info "  $ns: Namespace not found (OK)"
  fi
done

echo ""
log_info "Cleanup complete!"
echo ""
log_warn "Note: The following are NOT deleted (managed by Terraform):"
echo "  - Helm releases (ArgoCD, Istio, etc.)"
echo "  - CRDs (ElasticSearch, Istio, Kyverno, etc.)"
echo "  - Core namespaces (argocd, istio-system, kube-system, etc.)"
echo "  - Infrastructure components (AWS Load Balancers, etc.)"
echo ""
log_info "Note: Kyverno resources ARE pre-cleaned to prevent Helm uninstall deadlock"
echo ""
log_info "To fully destroy the cluster, run: terraform destroy"
echo ""

