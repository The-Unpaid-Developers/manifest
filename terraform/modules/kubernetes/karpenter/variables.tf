variable "unpaid_developers_singapore_eks_oidc_url" {
  description = "URL of the OIDC provider associated with the EKS cluster"
  type        = string
}

variable "unpaid_developers_singapore_eks_oidc_arn" {
  description = "ARN of the OIDC provider associated with the EKS cluster"
  type        = string
}

variable "unpaid_developers_eks_nodes_role_name" {
  description = "Name of the IAM role for the EKS nodes"
  type        = string
}

variable "unpaid_developers_singapore_eks_cluster_id" {
  description = "ID of the EKS cluster"
  type        = string
}

variable "unpaid_developers_singapore_eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}
