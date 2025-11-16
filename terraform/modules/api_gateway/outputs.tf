output "api_gateway_invoke_url" {
  description = "The base URL to invoke the API Gateway stage."
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_gateway_id" {
  description = "The ID of the API Gateway REST API."
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_execution_arn" {
  description = "The execution ARN of the API Gateway REST API."
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "api_gateway_custom_domain_name" {
  description = "The custom domain name for the API Gateway (if enabled)."
  value       = var.rest_api_enable_custom_domain ? aws_api_gateway_domain_name.main[0].domain_name : null
}

output "api_gateway_custom_domain_url" {
  description = "The full URL for the custom domain (if enabled)."
  value       = var.rest_api_enable_custom_domain ? "https://${aws_api_gateway_domain_name.main[0].domain_name}" : null
}