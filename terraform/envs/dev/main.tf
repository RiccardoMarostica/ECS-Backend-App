## COGNITO USER POOL
module "cognito_user_pool" {
  source = "../../modules/cognito"


  user_pool_name        = "${var.project_name}-${var.environment}-user-pool"
  user_pool_client_name = "${var.project_name}-${var.environment}-user-pool-client"
  user_pool_domain_name = "${var.project_name}-${var.environment}-user-pool-domain"
}

## VPC
module "vpc" {
  source = "../../modules/vpc"

  # Global variables
  aws_region                      = var.aws_region
  environment                     = var.environment
  project_name                    = var.project_name

  # VPC variables  
  vpc_cidr_block                  = var.vpc_cidr_block
  vpc_subnet_public_a_cidr_block  = var.vpc_subnet_public_a_cidr_block
  vpc_subnet_public_b_cidr_block  = var.vpc_subnet_public_b_cidr_block
  vpc_subnet_private_a_cidr_block = var.vpc_subnet_private_a_cidr_block
  vpc_subnet_private_b_cidr_block = var.vpc_subnet_private_b_cidr_block
}

## APPLICATION LOAD BALANCER
module "alb" {
  source = "../../modules/alb"

  # Global variables
  aws_region          = var.aws_region
  environment         = var.environment
  project_name        = var.project_name

  # VPC variables
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_private_subnets = module.vpc.private_subnets
}

## API GATEWAY
module "rest_api" {
  source = "../../modules/api_gateway"

  # API variable
  rest_api_name                        = "${var.project_name}-${var.environment}-rest-api"
  rest_api_authorizer_name             = "${var.project_name}-${var.environment}-rest-api-authorizer"
  rest_api_authorizer_cognito_provider = [module.cognito_user_pool.cognito_user_pool_arn]
  rest_api_stage_name                  = var.environment

  # VPC Link variables
  alb_listener_arn                     = module.alb.listener_arn
  alb_vpc_link_id                      = module.alb.alb_vpc_link_id
}

## ECS CLUSTER
module "ecs_cluster" {
  source = "../../modules/ecs/cluster"

  # API variable
  aws_region                = var.aws_region
  environment               = var.environment
  project_name              = var.project_name

  # ECS cluster variables
  enable_container_insights = true
}

## ECS SERVICE - USER
module "users_service" {
  source = "../../modules/ecs/service"

  # Global variables
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
  service_name = "users"

  # ECS cluster
  ecs_cluster_id = module.ecs_cluster.cluster_id

  # Networking
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_security_group_id = module.alb.alb_sg_id

  # Load balancing
  alb_listener_arn       = module.alb.listener_arn
  listener_rule_priority = 100
  path_pattern           = ["/users", "/users/*"]
  health_check_path      = "/users/health"

  # Container configuration
  container_image  = var.users_service_image
  container_port   = 8080
  container_cpu    = 256
  container_memory = 512

  # Service configuration
  desired_count = 2

  # Logging
  log_retention_days = 30

  # Auto-scaling
  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 5
  autoscaling_target_cpu   = 70
}
