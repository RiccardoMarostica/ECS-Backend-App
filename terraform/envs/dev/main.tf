module "cognito_user_pool" {
  source = "../../modules/cognito"

  user_pool_name        = "${var.project_name}-${var.environment}-user-pool"
  user_pool_client_name = "${var.project_name}-${var.environment}-user-pool-client"
  user_pool_domain_name = "${var.project_name}-${var.environment}-user-pool-domain"
}

module "rest_api" {
  source = "../../modules/api_gateway"

  rest_api_name                        = "${var.project_name}-${var.environment}-rest-api"
  rest_api_authorizer_name             = "${var.project_name}-${var.environment}-rest-api-authorizer"
  rest_api_authorizer_cognito_provider = [module.cognito_user_pool.cognito_user_pool_arn]
  rest_api_stage_name                  = var.environment
}
