output "vpc_id" {
  value = aws_vpc.unpaid_developers_singapore_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.unpaid_developers_singapore_public_subnet_1.id,
    aws_subnet.unpaid_developers_singapore_public_subnet_2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.unpaid_developers_singapore_private_subnet_1.id,
    aws_subnet.unpaid_developers_singapore_private_subnet_2.id
  ]
}

output "unpaid_developers_singapore_db_subnet_group_name" {
  value = aws_db_subnet_group.unpaid_developers_singapore_db_subnet_group.name
}

output "unpaid_developers_singapore_security_group_id" {
  value = aws_security_group.unpaid_developers_singapore_security_group.id
}