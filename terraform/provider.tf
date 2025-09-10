terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.72.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.16.1"
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
data "aws_eks_cluster" "cluster" {
  name = module.eks.unpaid_developers_singapore_eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.unpaid_developers_singapore_eks_cluster_id
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# define kubeconfig for kubectl
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
