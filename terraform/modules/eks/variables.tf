variable "public_subnet_ids" {
  description = "List of IDs of public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of IDs of private subnets"
  type        = list(string)
}

variable "eks_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt secrets in EKS"
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS Kubernetes cluster version"
  type        = string
}

# GPU Node Group Variables
variable "gpu_instance_types" {
  description = "List of GPU instance types for the GPU node group"
  type        = list(string)
  default     = ["g4dn.xlarge"]
}

variable "gpu_desired_size" {
  description = "Desired number of GPU nodes"
  type        = number
  default     = 1
}

variable "gpu_min_size" {
  description = "Minimum number of GPU nodes"
  type        = number
  default     = 0
}

variable "gpu_max_size" {
  description = "Maximum number of GPU nodes"
  type        = number
  default     = 3
}
