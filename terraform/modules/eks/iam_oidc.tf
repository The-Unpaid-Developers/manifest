# create the OpenID Connect Provider for the EKS cluster
# this connect provider is then used by karpenter to authenticate with the EKS cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider

data "tls_certificate" "unpaid_developers_singapore_eks_tls" {
    url = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "unpaid_developers_singapore_eks_oidc" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.unpaid_developers_singapore_eks_tls.certificates.0.sha1_fingerprint]
    url = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.identity.0.oidc.0.issuer
}