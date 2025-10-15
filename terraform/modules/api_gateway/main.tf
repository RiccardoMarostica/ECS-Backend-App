resource "aws_api_gateway_rest_api" "main" {
  name                         = var.rest_api_name
  description                  = "REST API used to access the resources in ECS"
  disable_execute_api_endpoint = var.rest_api_disable_execute_endpoint

  endpoint_configuration {
    ip_address_type = var.rest_api_endpoint_ip_address_type
    types           = var.rest_api_endpoint_type
  }
}
