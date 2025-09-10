#tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "unpaid_developers_singapore_public_subnet_1" {
  vpc_id                  = aws_vpc.unpaid_developers_singapore_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  #checkov:skip=CKV_AWS_130:Subnet is intended to be public and assign public IPs by default
  map_public_ip_on_launch = true

  # note: k8s tags are necessary for k8s to manage the subnets
  # format: kubernetes.io/role/{role-name} (elb, internal-elb, etc)
  # format: kubernetes.io/cluster/{cluster-name} (owned, shared, etc)
  # owned means the k8s has full control over the subnet
  tags = {
    Name                                   = "unpaid-developers-singapore-public-subnet-1"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/unpaid-developers-singapore-eks-cluster" = "owned"
  }
}

#tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "unpaid_developers_singapore_public_subnet_2" {
  vpc_id                  = aws_vpc.unpaid_developers_singapore_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  #checkov:skip=CKV_AWS_130:Subnet is intended to be public and assign public IPs by default
  map_public_ip_on_launch = true
  tags = {
    Name                                   = "unpaid-developers-singapore-public-subnet-1"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/unpaid-developers-singapore-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "unpaid_developers_singapore_private_subnet_1" {
  vpc_id                  = aws_vpc.unpaid_developers_singapore_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "unpaid-developers-singapore-private-subnet-1"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/unpaid-developers-singapore-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "unpaid_developers_singapore_private_subnet_2" {
  vpc_id                  = aws_vpc.unpaid_developers_singapore_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "unpaid-developers-singapore-private-subnet-2"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/unpaid-developers-singapore-eks-cluster" = "owned"
  }
}

# RDS DB Subnet Group
# Temporarily giving it public subnets for testing
resource "aws_db_subnet_group" "unpaid_developers_singapore_db_subnet_group" {
  name       = "unpaid-developers-singapore-db-subnet-group"
  subnet_ids = [
    aws_subnet.unpaid_developers_singapore_public_subnet_1.id,
    aws_subnet.unpaid_developers_singapore_public_subnet_2.id
  ]

  tags = {
    Name = "unpaid-developers-singapore-db-subnet-group"
  }
}