# deploying karpenter using helm
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.16.3"

  values = [
    yamlencode({
      # provides karpenter permissions to manage nodes
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.unpaid_developers_karpenter_controller_role.arn
        }
      }
      clusterName     = var.unpaid_developers_singapore_eks_cluster_id
      clusterEndpoint = var.unpaid_developers_singapore_eks_cluster_endpoint
      # provides EC2 instances permissions upon launching
      aws = {
        defaultInstanceProfile = aws_iam_instance_profile.unpaid_developers_karpenter_profile.name
      }
    })
  ]

}
