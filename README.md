# Kubernetes Manifest Management

This repository contains Kubernetes manifests and scripts for managing the FYP cluster infrastructure.

## 📁 Directory Structure

```
manifest/
├── k8s/
│   ├── init_cluster.sh          # Initialize and deploy cluster resources
│   ├── destroy_cluster.sh       # Clean up cluster resources
│   ├── CLEANUP_GUIDE.md         # Detailed cleanup documentation
│   ├── application/             # Application service manifests
│   │   ├── chatbot-service/
│   │   ├── core-service/
│   │   ├── diagram-service/
│   │   ├── frontend/
│   │   └── proxy-service/
│   ├── init_resources/          # Initial cluster resources
│   │   ├── logging/             # ElasticSearch, Kibana, Fluentd
│   │   ├── monitoring/          # Grafana, Kiali, Prometheus
│   │   ├── operations/          # ArgoCD, Karpenter
│   │   └── storage/             # Storage classes
│   ├── kyverno_policies/        # Policy enforcement
│   ├── namespaces/              # Namespace definitions
│   ├── networking/              # Istio Gateway configuration
│   └── secrets/                 # Credentials and secrets
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- kubectl installed
- Access to the EKS cluster
- Terraform infrastructure already deployed

### Initialize Cluster

```bash
cd k8s
./init_cluster.sh
```

This will:

1. Update kubeconfig
2. Create namespaces
3. Apply CRDs
4. Deploy Argo Rollouts
5. Deploy init resources (logging, monitoring, operations)
6. Configure secrets
7. Integrate SSL certificates
8. Configure networking

### Clean Up Cluster

```bash
cd k8s
./destroy_cluster.sh
```

This will safely remove all application workloads and configuration while preserving Terraform-managed infrastructure.

## 📚 Scripts

### `init_cluster.sh`

Initializes the cluster with all necessary resources and applications.

**Usage:**

```bash
./init_cluster.sh
```

**What it does:**

- Applies namespaces and CRDs
- Deploys Argo Rollouts
- Configures logging (ElasticSearch, Kibana, Fluentd)
- Sets up monitoring (Grafana, Kiali, Prometheus)
- Deploys ArgoCD applications
- Configures Karpenter provisioners
- Integrates SSL certificates
- Applies networking configuration

### `destroy_cluster.sh`

Safely tears down cluster resources without affecting Terraform-managed infrastructure.

**Usage:**

```bash
./destroy_cluster.sh
```

**What it does:**

- ✅ Deletes admission webhooks (prevents deadlock)
- ✅ Removes ArgoCD applications
- ✅ Cleans up application workloads
- ✅ Removes init resources
- ✅ Deletes secrets and certificates
- ✅ Uninstalls Argo Rollouts
- ✅ Force deletes stuck resources
- ❌ Does NOT delete Terraform-managed resources

## 🏗️ Architecture

### Infrastructure Layers

```
┌─────────────────────────────────────────┐
│   Application Layer (ArgoCD Apps)      │
│   - Services: chatbot, core, diagram   │
│   - Frontend, proxy                     │
├─────────────────────────────────────────┤
│   Operations Layer                      │
│   - Monitoring: Grafana, Kiali         │
│   - Logging: ELK Stack                 │
│   - ArgoCD: GitOps                     │
├─────────────────────────────────────────┤
│   Infrastructure Layer (Terraform)      │
│   - Helm: ArgoCD, Istio, Kyverno       │
│   - EKS: Cluster, Nodes, Networking    │
└─────────────────────────────────────────┘
```

### Resource Management

- **Terraform**: Manages infrastructure (EKS, Helm releases, core services)
- **ArgoCD**: Manages application deployments (GitOps)
- **Scripts**: Manage configuration and bootstrapping

## 🔐 Security

### Secrets Management

Secrets are stored in the `secrets/` directory and should be:

- Encrypted at rest
- Not committed to version control (use `.gitignore`)
- Managed via CI/CD or secrets management tools

### Policy Enforcement

Kyverno policies in `kyverno_policies/` enforce:

- No latest tags
- Resource requests/limits
- No default namespace usage
- No deprecated APIs
- Security best practices

## 🌐 Networking

### Domains

The cluster serves traffic for:

- `fyp.bchwey.com` - Main application
- `argocd.bchwey.com` - ArgoCD UI
- `kibana.bchwey.com` - Kibana dashboard
- `grafana.bchwey.com` - Grafana monitoring
- `kiali.bchwey.com` - Kiali service mesh

### SSL/TLS

Multi-domain certificate from ZeroSSL:

- Certificate files: `certificates/`
- Secret name: `bchwey-zerossl-tls-secret`
- Namespace: `istio-ingress`

## 🔄 GitOps Workflow

1. **Code Push**: Developers push code to repositories
2. **CI/CD**: GitHub Actions build and push images
3. **ArgoCD Image Updater**: Detects new images
4. **ArgoCD Sync**: Updates application manifests
5. **Argo Rollouts**: Performs blue-green/canary deployments
6. **Monitoring**: Grafana, Kiali track deployment health

## 🛠️ Troubleshooting

### Common Issues

#### Resources Won't Delete

**Symptom**: Resources stuck in "Terminating" state

**Solution**: Run `destroy_cluster.sh` which handles this automatically by:

1. Deleting admission webhooks first
2. Force deleting stuck pods
3. Removing finalizers
4. Cleaning up Helm hook jobs

#### Helm Release Stuck Uninstalling

**Symptom**: `helm list` shows release in "uninstalling" status

**Solution**: See [CLEANUP_GUIDE.md](k8s/CLEANUP_GUIDE.md) - The script handles this automatically.

#### Nodes NotReady

**Symptom**: Pods won't schedule, resources won't delete

**Impact**: The `destroy_cluster.sh` script is designed to work even with NotReady nodes.

**Investigation**:

```bash
kubectl get nodes
kubectl describe node <node-name>
```

#### Webhook Timeout Errors

**Symptom**: API operations timeout or fail

**Solution**:

```bash
# Manually delete problematic webhooks
kubectl delete validatingwebhookconfigurations <webhook-name>
kubectl delete mutatingwebhookconfigurations <webhook-name>
```

## 📊 Monitoring & Observability

- **Grafana**: `https://grafana.bchwey.com` - Metrics and dashboards
- **Kiali**: `https://kiali.bchwey.com` - Service mesh visualization
- **Kibana**: `https://kibana.bchwey.com` - Log analysis
- **ArgoCD**: `https://argocd.bchwey.com` - Deployment status

## 🔧 Maintenance

### Regular Tasks

1. **Update Images**: ArgoCD Image Updater handles automatically
2. **Rotate Certificates**: Update `certificates/` and run relevant parts of `init_cluster.sh`
3. **Update CRDs**: Manually apply new CRD versions
4. **Backup**: Ensure ArgoCD configs and secrets are backed up

### Cluster Upgrades

1. Use Terraform to upgrade EKS version
2. Update node groups
3. Update Kubernetes manifests if needed
4. Test in staging first

## 📝 Best Practices

1. ✅ Always use `destroy_cluster.sh` before `terraform destroy`
2. ✅ Test changes in a development cluster first
3. ✅ Keep Terraform state backed up
4. ✅ Use ArgoCD for application deployments
5. ✅ Monitor webhook configurations to prevent deadlocks
6. ✅ Document any manual changes
7. ❌ Don't manually delete Helm releases (use Terraform)
8. ❌ Don't commit secrets to Git
9. ❌ Don't delete CRDs without checking dependencies

## 🚨 Emergency Procedures

### Complete Cluster Reset

```bash
# 1. Clean up applications and configuration
cd k8s
./destroy_cluster.sh

# 2. Destroy and recreate infrastructure
cd ../terraform
terraform destroy
terraform apply

# 3. Reinitialize cluster
cd ../manifest/k8s
./init_cluster.sh
```

### Force Delete All Resources

```bash
# Use with EXTREME caution
kubectl delete all --all -n <namespace> --force --grace-period=0
```
