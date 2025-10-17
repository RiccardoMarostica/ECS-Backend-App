module "cognito_user_pool" {
  source = "../../modules/cognito"

  user_pool_name        = "${var.project_name}-${var.environment}-user-pool"
  user_pool_client_name = "${var.project_name}-${var.environment}-user-pool-client"
  user_pool_domain_name = "${var.project_name}-${var.environment}-user-pool-domain"
}

module "vpc" {
  source = "../../modules/vpc"

  aws_region                      = var.aws_region
  environment                     = var.environment
  project_name                    = var.project_name
  vpc_cidr_block                  = var.vpc_cidr_block
  vpc_subnet_public_a_cidr_block  = var.vpc_subnet_public_a_cidr_block
  vpc_subnet_public_b_cidr_block  = var.vpc_subnet_public_b_cidr_block
  vpc_subnet_private_a_cidr_block = var.vpc_subnet_private_a_cidr_block
  vpc_subnet_private_b_cidr_block = var.vpc_subnet_private_b_cidr_block
}

module "alb" {
  source = "../../modules/alb"

  aws_region          = var.aws_region
  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_private_subnets = module.vpc.private_subnets
}


module "rest_api" {
  source = "../../modules/api_gateway"

  rest_api_name                        = "${var.project_name}-${var.environment}-rest-api"
  rest_api_authorizer_name             = "${var.project_name}-${var.environment}-rest-api-authorizer"
  rest_api_authorizer_cognito_provider = [module.cognito_user_pool.cognito_user_pool_arn]
  rest_api_stage_name                  = var.environment
}
