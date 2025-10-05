output "aws_auth_configmap" {
  description = "AWS auth ConfigMap for EKS cluster authentication"
  value       = kubernetes_config_map.aws_auth
}

