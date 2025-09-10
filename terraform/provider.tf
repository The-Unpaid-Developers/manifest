terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.72.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.16.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.33.0"
    }
  }
  required_version = ">= 1.2.0" # sets terraform CLI version
}

provider "aws" {
  region = "ap-southeast-1"
}

# allow terraform to authenticate helm with the EKS cluster
provider "helm" {
  kubernetes {
    host                   = module.eks.unpaid_developers_singapore_eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.unpaid_developers_singapore_eks_cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.unpaid_developers_singapore_eks_cluster_id, "--region", "ap-southeast-1"]
      command     = "aws"
    }
  }
}

# define kubeconfig for kubectl
provider "kubernetes" {
  host                   = module.eks.unpaid_developers_singapore_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.unpaid_developers_singapore_eks_cluster_certificate_authority_data)
  token                  = module.eks.unpaid_developers_singapore_eks_cluster_token
}
