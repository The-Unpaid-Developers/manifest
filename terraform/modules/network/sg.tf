# # Create a Security Group for the application
# #tfsec:ignore:aws-ec2-no-public-ingress-sgr
# #tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "unpaid_developers_singapore_security_group" {
  name        = "unpaid-developers-singapore-security-group"
  description = "Security group for the application"
  vpc_id      = aws_vpc.unpaid_developers_singapore_vpc.id

  #checkov:skip=CKV_AWS_260:Allowing all traffic is intentional
  #checkov:skip=CKV_AWS_24:Allowing all traffic is intentional
  #checkov:skip=CKV_AWS_161:Not using IAM authentication for now
  #checkov:skip=CKV2_AWS_5:Ignore security group attachments
  ingress {
    description = "SSH Access from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Network access from anywhere to NLB
  ingress {
    description = "HTTP Access from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Access from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Database Access
  ingress {
    description = "Database Access from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access from VPC Security Group"
    from_port   = 0
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  # Egress rule
  egress {
    description = "Allow all traffic out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "unpaid_developers_singapore-security-group"
  }
}
