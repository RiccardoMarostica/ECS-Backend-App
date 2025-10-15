resource "aws_cognito_user_pool" "main" {

  name                     = var.user_pool_name
  auto_verified_attributes = var.auto_verified_attributes
  deletion_protection      = local.deletion_protection
  user_pool_tier           = var.user_pool_tier

  password_policy {
    minimum_length    = var.password_policy_min_length
    require_lowercase = var.password_policy_require_lowercase
    require_numbers   = var.password_policy_require_numbers
    require_symbols   = var.password_policy_require_symbols
    require_uppercase = var.password_policy_require_uppercase
  }

}

resource "aws_cognito_user_pool_client" "main_client" {

  name         = var.user_pool_client_name
  user_pool_id = aws_cognito_user_pool.main.id

  access_token_validity  = var.user_pool_client_access_token_validity
  id_token_validity      = var.user_pool_client_id_token_validity
  refresh_token_validity = var.user_pool_client_refresh_token_validity

  generate_secret     = var.user_pool_client_generate_scret
  explicit_auth_flows = var.user_pool_client_explicit_auth_flows

  allowed_oauth_flows_user_pool_client = var.user_pool_client_allow_oauth_flows
  allowed_oauth_flows                  = local.allowed_oauth_flows
  allowed_oauth_scopes                 = local.allowed_oauth_scopes
  callback_urls                        = local.callback_urls
  logout_urls                          = local.logout_urls

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

}

resource "aws_cognito_user_pool_domain" "main_domain" {
  domain          = var.user_pool_domain_name
  user_pool_id    = aws_cognito_user_pool.main.id
  certificate_arn = local.certificate_arn
}
