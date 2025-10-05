# General purpose node group for standard workloads
resource "aws_eks_node_group" "unpaid_developers_singapore_nodes" {
  cluster_name    = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.name
  node_group_name = "unpaid-developers-singapore-nodes"
  node_role_arn   = aws_iam_role.unpaid_developers_eks_nodes_role.arn

  subnet_ids = [
    var.private_subnet_ids[0],
    var.private_subnet_ids[1]
  ]

  # capacity_type  = "SPOT"
  instance_types = ["t3.2xlarge"]

  disk_size = 100

  scaling_config {
    desired_size = 4
    max_size     = 7
    min_size     = 1
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

# GPU node group for GPU-accelerated workloads
resource "aws_eks_node_group" "unpaid_developers_singapore_gpu_nodes" {
  cluster_name    = aws_eks_cluster.unpaid_developers_singapore_eks_cluster.name
  node_group_name = "unpaid-developers-singapore-gpu-nodes"
  node_role_arn   = aws_iam_role.unpaid_developers_eks_nodes_role.arn

  subnet_ids = [
    var.private_subnet_ids[0],
    var.private_subnet_ids[1]
  ]

  # Use EKS-optimized AMI with GPU support (AL2023 with NVIDIA drivers)
  ami_type = "AL2023_x86_64_NVIDIA"

  # GPU instance types - g4dn for cost-effective GPU workloads
  instance_types = var.gpu_instance_types

  disk_size = 200 # Larger disk for GPU workloads and models

  scaling_config {
    desired_size = var.gpu_desired_size
    max_size     = var.gpu_max_size
    min_size     = var.gpu_min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role        = "gpu"
    workload    = "gpu-compute"
    gpu-enabled = "true"
  }

  # Taint GPU nodes so only GPU workloads with tolerations can be scheduled
  taint {
    key    = "nvidia.com/gpu"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  # Tags for cost tracking and management
  tags = {
    Name        = "unpaid-developers-gpu-node"
    Environment = "production"
    NodeType    = "gpu"
    ManagedBy   = "terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.unpaid-developers-eks-nodes-AmazonRDSDataFullAccess
  ]

  # Lifecycle to prevent destruction during updates
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}
