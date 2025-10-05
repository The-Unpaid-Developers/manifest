# AWS related resources
module "network" {
  source = "./modules/network"
}

module "kms" {
  source = "./modules/kms"
}

module "eks" {
  source = "./modules/eks"

  private_subnet_ids  = module.network.private_subnet_ids
  public_subnet_ids   = module.network.public_subnet_ids
  eks_kms_key_arn     = module.kms.eks_kms_key_arn
  eks_cluster_version = var.eks_cluster_version
  
  # GPU node group configuration
  gpu_instance_types = var.gpu_instance_types
  gpu_desired_size   = var.gpu_desired_size
  gpu_min_size       = var.gpu_min_size
  gpu_max_size       = var.gpu_max_size
}

# Kubernetes related resources
module "kubernetes" {
  source = "./modules/kubernetes"

  # for IAM to access EKS
  unpaid_developers_eks_nodes_role_arn = module.eks.unpaid_developers_eks_nodes_role_arn
  aws_account_id                       = var.aws_account_id
  iam_user_name                        = var.iam_user_name
}

module "karpenter" {
  source = "./modules/kubernetes/karpenter"

  unpaid_developers_singapore_eks_oidc_url         = module.eks.unpaid_developers_singapore_eks_oidc_url
  unpaid_developers_singapore_eks_oidc_arn         = module.eks.unpaid_developers_singapore_eks_oidc_arn
  unpaid_developers_eks_nodes_role_name            = module.eks.unpaid_developers_eks_nodes_role_name
  unpaid_developers_singapore_eks_cluster_id       = module.eks.unpaid_developers_singapore_eks_cluster_id
  unpaid_developers_singapore_eks_cluster_endpoint = module.eks.unpaid_developers_singapore_eks_cluster_endpoint
  karpenter_chart_version                          = var.karpenter_chart_version
  aws_auth_configmap                               = module.kubernetes.aws_auth_configmap

  depends_on = [module.eks, module.kubernetes]
}

module "argocd" {
  source = "./modules/kubernetes/argocd"

  argocd_chart_version               = var.argocd_chart_version
  argocd_image_updater_chart_version = var.argocd_image_updater_chart_version
  aws_auth_configmap                 = module.kubernetes.aws_auth_configmap

  depends_on = [module.eks, module.kubernetes]
}

module "istio" {
  source = "./modules/kubernetes/istio"

  unpaid_developers_singapore_eks_cluster_name = module.eks.unpaid_developers_singapore_eks_cluster_name
  istio_chart_version                          = var.istio_chart_version
  aws_auth_configmap                           = module.kubernetes.aws_auth_configmap

  depends_on = [module.eks, module.kubernetes]
}

module "metrics_server" {
  source = "./modules/kubernetes/metrics_server"

  metrics_server_chart_version = var.metrics_server_chart_version
  aws_auth_configmap           = module.kubernetes.aws_auth_configmap

  depends_on = [module.eks, module.kubernetes]
}

module "kyverno" {
  source = "./modules/kubernetes/kyverno"

  kyverno_chart_version = var.kyverno_chart_version
  aws_auth_configmap    = module.kubernetes.aws_auth_configmap

  depends_on = [module.eks, module.kubernetes, module.istio]
}
