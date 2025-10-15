output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn  
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.main_client.id
}

output "cognito_user_pool_client_secret" {
  description = "The client secret of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.main_client.client_secret
  sensitive   = true
}

output "cognito_user_pool_domain" {
  description = "The domain of the Cognito User Pool"
  value       = aws_cognito_user_pool_domain.main_domain.domain
}