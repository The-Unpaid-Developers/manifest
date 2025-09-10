# Route table for the private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.unpaid_developers_singapore_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.unpaid_developers_singapore_vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.unpaid_developers_singapore_internet_gateway.id
  }

  tags = {
    Name = "public-rt"
  }
}


resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.unpaid_developers_singapore_private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.unpaid_developers_singapore_private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.unpaid_developers_singapore_public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.unpaid_developers_singapore_public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
