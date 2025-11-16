#####
# API Gateway
# This creates an API Gateway resource with configuration based on input variables.
#######
resource "aws_api_gateway_rest_api" "main" {
  name                         = var.rest_api_name
  description                  = "REST API used to access the resources in ECS"
  disable_execute_api_endpoint = var.rest_api_disable_execute_endpoint

  endpoint_configuration {
    ip_address_type = var.rest_api_endpoint_ip_address_type
    types           = [var.rest_api_endpoint_type]
  }
}

#####
# API Gateway - Cognito Authorizer
# This creates an Cognito Authorizer resource with configuration based on input variables.
# The authorizer is used to authenticate requests to the API Gateway.
#######
resource "aws_api_gateway_authorizer" "cognito" {
  name                             = var.rest_api_authorizer_name
  rest_api_id                      = aws_api_gateway_rest_api.main.id
  type                             = var.rest_api_authorizer_type
  authorizer_result_ttl_in_seconds = var.rest_api_authorizer_ttl
  provider_arns                    = var.rest_api_authorizer_cognito_provider
  identity_source                  = "method.request.header.Authorization"
}

#####
# API Gateway - PROXY Resource and Method
# This creates a PROXY Resource and Method for the API Gateway.
# The PROXY resource is used to forward requests to the ALB (Application Load Balancer).
# The PROXY integration uses a VPC Link to communicate with the ALB.
#######
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

# Create PROXY Method with ANY HTTP Method
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id

}

# Create PROXY Integration with VPC Link
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

#####
# API Gateway - Deployment
# This creates a deployment for the API Gateway.
# The deployment is used to apply the configuration changes to the API Gateway.
#  The stage is used to activate the deployment and make it available for requests.
#######
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

# Creates the API Gateway stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.rest_api_stage_name
}



#####
# API Gateway - Custom domain
# This creates a Custom domain name for the API Gateway.
# It attaches the public ACM Certificate to the API Gateway, and provides access to the API via a custom domain name.
#######
resource "aws_api_gateway_domain_name" "main" {
  count = var.rest_api_enable_custom_domain ? 1 : 0

  certificate_arn = var.rest_api_custom_domain_certificate_arn
  domain_name     = var.rest_api_custom_domain_name

  endpoint_configuration {
    types = [var.rest_api_endpoint_type]
  }
}

# This attaches the API Gateway to the custom domain name
resource "aws_route53_record" "main" {
  count = var.rest_api_enable_custom_domain ? 1 : 0

  name    = aws_api_gateway_domain_name.main[0].domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    evaluate_target_health = true
    name                   = var.rest_api_endpoint_type == "EDGE" ? aws_api_gateway_domain_name.main[0].cloudfront_domain_name : aws_api_gateway_domain_name.main[0].regional_domain_name
    zone_id                = var.rest_api_endpoint_type == "EDGE" ? aws_api_gateway_domain_name.main[0].cloudfront_zone_id : aws_api_gateway_domain_name.main[0].regional_zone_id
  }
}

# Create a base path mapping to the stage
resource "aws_api_gateway_base_path_mapping" "main" {
  count = var.rest_api_enable_custom_domain ? 1 : 0

  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  domain_name = aws_api_gateway_domain_name.main[0].domain_name

  depends_on = [aws_api_gateway_domain_name.main]
}
