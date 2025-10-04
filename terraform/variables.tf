variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "iam_user_name" {
  description = "IAM user name"
  type        = string
}

# Version variables for Helm charts and Kubernetes components
variable "eks_cluster_version" {
  description = "EKS Kubernetes cluster version"
  type        = string
  default     = "1.31"
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = "v0.16.3"
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.46.8"
}

variable "argocd_image_updater_chart_version" {
  description = "ArgoCD Image Updater Helm chart version"
  type        = string
  default     = "0.8.4"
}

variable "istio_chart_version" {
  description = "Istio Helm chart version (applies to base, istiod, and gateway)"
  type        = string
  default     = "1.21.0"
}

variable "kyverno_chart_version" {
  description = "Kyverno Helm chart version"
  type        = string
  default     = "3.3.1"
}

variable "metrics_server_chart_version" {
  description = "Metrics Server Helm chart version"
  type        = string
  default     = "3.12.0"
}
