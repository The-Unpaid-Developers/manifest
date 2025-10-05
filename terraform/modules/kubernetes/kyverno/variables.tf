variable "kyverno_chart_version" {
  description = "Kyverno Helm chart version"
  type        = string
}

variable "aws_auth_configmap" {
  description = "AWS auth ConfigMap dependency"
  type        = any
}
