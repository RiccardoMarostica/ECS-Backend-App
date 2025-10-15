output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the VPC."
  value       = aws_vpc.main.arn
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "public_route_table_arn" {
  description = "The ARN of the public route table"
  value       = aws_route_table.public.arn
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

output "private_route_table_arn" {
  description = "The ARN of the private route table"
  value       = aws_route_table.private.arn
}