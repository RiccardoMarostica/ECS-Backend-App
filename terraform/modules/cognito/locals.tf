locals {
  # Cognito User Pool
  deletion_protection = var.deletion_protection ? "ACTIVE" : "INACTIVE"

  # Cognito User Pool client
  allowed_oauth_flows          = var.user_pool_client_allow_oauth_flows ? var.user_pool_client_allowed_oauth_flows : null
  allowed_oauth_scopes         = var.user_pool_client_allow_oauth_flows ? var.user_pool_client_allowed_oauth_scopes : null
  callback_urls                = var.user_pool_client_allow_oauth_flows ? var.user_pool_client_callback_urls : null
  logout_urls                  = var.user_pool_client_allow_oauth_flows ? var.user_pool_client_logout_urls : null
  supported_identity_providers = var.user_pool_client_allow_oauth_flows ? ["COGNITO"] : null

  # Cognito User Pool domain
  certificate_arn = var.user_pool_domain_certificate_arn != "" ? var.user_pool_domain_certificate_arn : null
}
