# create a role to be attached to the EKS cluster
resource "aws_iam_role" "unpaid_developers_eks_cluster_role" {
  name = "unpaid-developers-eks-cluster-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
  }
  POLICY
}

# attaches the AmazonEKSClusterPolicy to the role
# this policy allows the EKS cluster to manage some AWS resources
# https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
resource "aws_iam_role_policy_attachment" "unpaid_developers_eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.unpaid_developers_eks_cluster_role.name
}

