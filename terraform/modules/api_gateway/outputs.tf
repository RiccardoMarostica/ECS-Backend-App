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