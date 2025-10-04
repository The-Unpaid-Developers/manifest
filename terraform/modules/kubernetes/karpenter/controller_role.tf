data "aws_iam_policy_document" "unpaid_developers_karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.unpaid_developers_singapore_eks_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    principals {
      identifiers = [var.unpaid_developers_singapore_eks_oidc_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "unpaid_developers_karpenter_controller_role" {
  assume_role_policy = data.aws_iam_policy_document.unpaid_developers_karpenter_controller_assume_role_policy.json
  name               = "karpenter-controller"
}

resource "aws_iam_policy" "unpaid_developers_karpenter_controller_policy" {
  policy = file("${path.module}/controller_trust_policy.json")
  name   = "KarpenterController"
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.unpaid_developers_karpenter_controller_role.name
  policy_arn = aws_iam_policy.unpaid_developers_karpenter_controller_policy.arn
}

resource "aws_iam_instance_profile" "unpaid_developers_karpenter_profile" {
  name = "KarpenterNodeInstanceProfile"
  role = var.unpaid_developers_eks_nodes_role_name
}
