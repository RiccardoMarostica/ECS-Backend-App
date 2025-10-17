resource "aws_api_gateway_rest_api" "main" {
  name                         = var.rest_api_name
  description                  = "REST API used to access the resources in ECS"
  disable_execute_api_endpoint = var.rest_api_disable_execute_endpoint

  endpoint_configuration {
    ip_address_type = var.rest_api_endpoint_ip_address_type
    types           = [var.rest_api_endpoint_type]
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                             = var.rest_api_authorizer_name
  rest_api_id                      = aws_api_gateway_rest_api.main.id
  type                             = var.rest_api_authorizer_type
  authorizer_result_ttl_in_seconds = var.rest_api_authorizer_ttl
  provider_arns                    = var.rest_api_authorizer_cognito_provider
  identity_source                  = "method.request.header.Authorization"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id

}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = var.alb_vpc_link_id
  uri                     = var.alb_listener_arn
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.proxy.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.rest_api_stage_name
}
