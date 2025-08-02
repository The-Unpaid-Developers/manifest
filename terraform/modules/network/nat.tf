resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "unpaid-developers-singapore-nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.unpaid_developers_singapore_public_subnet_1.id

  tags = {
    Name = "unpaid-developers-singapore-nat"
  }

  depends_on = [
    aws_internet_gateway.unpaid_developers_singapore_internet_gateway]
}
