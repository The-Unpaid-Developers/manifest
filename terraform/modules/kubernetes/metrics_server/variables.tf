variable "metrics_server_chart_version" {
  description = "Metrics Server Helm chart version"
  type        = string
}

variable "aws_auth_configmap" {
  description = "AWS auth ConfigMap dependency"
  type        = any
}
