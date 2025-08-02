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