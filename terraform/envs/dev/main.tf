module "cognito_user_pool" {
    source = "../../modules/cognito"

    user_pool_name = "${var.project_name}-${var.environment}-user-pool"
    user_pool_client_name = "${var.project_name}-${var.environment}-user-pool-client"
    user_pool_domain_name = "${var.project_name}-${var.environment}-user-pool-domain"
}