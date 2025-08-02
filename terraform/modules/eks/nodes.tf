resource "aws_eks_node_group" "unpaid_developers_singapore_nodes" {
  cluster_name    = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.name
  node_group_name = "unpaid-developers-singapore-nodes"
  node_role_arn   = aws_iam_role.unpaid_developers_eks_nodes_role.arn

  subnet_ids = [
    var.private_subnet_ids[0],
    var.private_subnet_ids[1]
  ]

  # commented out for presentation purposes
  # capacity_type  = "SPOT"
  instance_types = ["t3.2xlarge"]

  disk_size = 100

  scaling_config {
    desired_size = 4
    max_size     = 7
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonEKS_CNI_Policy,
  aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonRDSDataFullAccess]
}
