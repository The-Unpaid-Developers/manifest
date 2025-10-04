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

module "metrics_server" {
  source = "./modules/kubernetes/metrics_server"
}
