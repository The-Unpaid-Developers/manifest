# This file defines the IAM roles and policies for the worker nodes in the EKS cluster.
resource "aws_iam_role" "unpaid_developers_eks_nodes_role" {
  name = "unpaid-developers-eks-nodes-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# to allow the worker nodes to join the cluster
# https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html
resource "aws_iam_role_policy_attachment" "unpaid-developers-eks-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.unpaid_developers_eks_nodes_role.name
}

# to pull images from ECR
# https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html
resource "aws_iam_role_policy_attachment" "unpaid-developers-eks-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.unpaid_developers_eks_nodes_role.name
}

# to allow the worker nodes to connect to the cluster network
# https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html
resource "aws_iam_role_policy_attachment" "unpaid-developers-eks-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.unpaid_developers_eks_nodes_role.name
}

# allow worker nodes to access and modify RDS data
resource "aws_iam_role_policy_attachment" "unpaid-developers-eks-nodes-AmazonRDSDataFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  role       = aws_iam_role.unpaid_developers_eks_nodes_role.name
}

# allow worker nodes to access SES
resource "aws_iam_role_policy_attachment" "unpaid-developers-eks-nodes-AmazonSESFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
  role       = aws_iam_role.unpaid_developers_eks_nodes_role.name
}
# allow worker nodes to access DynamoDB
resource "aws_iam_role_policy_attachment" "unpaid-developers-eks-nodes-AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.unpaid_developers_eks_nodes_role.name
}

