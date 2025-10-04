# AWS related resources
module "network" {
  source = "./modules/network"
}

module "kms" {
  source = "./modules/kms"
}

module "eks" {
  source = "./modules/eks"

  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids
  eks_kms_key_arn    = module.kms.eks_kms_key_arn
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
}

module "argocd" {
  source = "./modules/kubernetes/argocd"
}

module "istio" {
  source = "./modules/kubernetes/istio"

  unpaid_developers_singapore_eks_cluster_name = module.eks.unpaid_developers_singapore_eks_cluster_name
}

module "metrics_server" {
  source = "./modules/kubernetes/metrics_server"
}

module "kyverno" {
  source = "./modules/kubernetes/kyverno"
}
