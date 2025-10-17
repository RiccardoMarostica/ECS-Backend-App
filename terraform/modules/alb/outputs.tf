# modules/alb/outputs.tf

output "alb_id" {
  description = "The ID of the ALB."
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = aws_lb_listener.http.arn
}

output "alb_sg_id" {
  description = "The ID of the ALB Security Group."
  value       = aws_security_group.alb.id  
}

output "alb_sg_arn" {
  description = "The ARN of the ALB Security Group."
  value       = aws_security_group.alb.arn  
}

output "alb_vpc_link_id" {
  description = "The ID of the ALB VPC Link."
  value       = aws_api_gateway_vpc_link.alb.id
}

output "alb_vpc_link_arn" {
  description = "The ARN of the ALB VPC Link."
  value       = aws_api_gateway_vpc_link.alb.arn
}