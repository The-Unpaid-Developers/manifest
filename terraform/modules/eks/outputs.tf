output "unpaid_developers_eks_nodes_role_arn" {
  value = aws_iam_role.unpaid_developers_eks_nodes_role.arn
}

output "unpaid_developers_singapore_eks_cluster_id" {
  value = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.id
}

output "unpaid_developers_singapore_eks_cluster_name" {
  value = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.name
}

output "unpaid_developers_singapore_eks_cluster_endpoint" {
  value = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.endpoint
}

output "unpaid_developers_singapore_eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.certificate_authority.0.data
}

output "unpaid_developers_singapore_eks_cluster_token" {
  value = data.aws_eks_cluster_auth.unpaid_developers_singapore_eks_cluster_auth.token
}

output "unpaid_developers_singapore_eks_oidc_url" {
  value = aws_iam_openid_connect_provider.unpaid_developers_singapore_eks_oidc.url
}

output "unpaid_developers_singapore_eks_oidc_arn" {
  value = aws_iam_openid_connect_provider.unpaid_developers_singapore_eks_oidc.arn
}

output "unpaid_developers_eks_nodes_role_name" {
  value = aws_iam_role.unpaid_developers_eks_nodes_role.name
}
