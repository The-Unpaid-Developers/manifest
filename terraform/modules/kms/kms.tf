resource "aws_kms_key" "eks_encryption" {
  #checkov:skip=CKV2_AWS_64:Using default KMS key policy is intentional
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

output "eks_kms_key_arn" {
  value = aws_kms_key.eks_encryption.arn
}

resource "aws_kms_key" "rds_encryption" {
  #checkov:skip=CKV2_AWS_64:Using default KMS key policy is intentional
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

output "rds_kms_key_arn" {
  value = aws_kms_key.rds_encryption.arn
}