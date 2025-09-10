resource "aws_internet_gateway" "unpaid_developers_singapore_internet_gateway" {
  vpc_id = aws_vpc.unpaid_developers_singapore_vpc.id

  tags = {
    Name = "unpaid-developers-singapore-internet-gateway"
  }
}