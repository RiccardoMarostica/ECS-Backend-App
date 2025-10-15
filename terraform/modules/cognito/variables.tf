## User Pool variables
variable "user_pool_name" {
  description = "The name of the user pool"
  type        = string
}

variable "password_policy_min_length" {
  description = "The minimum length of the password policy"
  type        = number
  default     = 8
}

variable "password_policy_require_lowercase" {
  description = "Whether the password policy requires lowercase characters"
  type        = bool
  default     = true
}

variable "password_policy_require_numbers" {
  description = "Whether the password policy requires numbers"
  type        = bool
  default     = true
}

variable "password_policy_require_symbols" {
  description = "Whether the password policy requires symbols"
  type        = bool
  default     = true
}

variable "password_policy_require_uppercase" {
  description = "Whether the password policy requires uppercase characters"
  type        = bool
  default     = true
}

variable "auto_verified_attributes" {
  description = "The attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "user_pool_tier" {
  description = "The user pool feature plan, or tier"
  type        = string
  default     = "LITE"
  validation {
    condition     = contains(["LITE", "ESSENTIAL", "PRO"], var.user_pool_tier)
    error_message = "Invalid user pool tier. Must be one of 'LITE', 'ESSENTIAL', or 'PRO'."
  }
}


## User Pool client variables
variable "user_pool_client_name" {
  description = "The name of the user pool client"
  type        = string
}

variable "user_pool_client_access_token_validity" {
  description = "The validity of the access token"
  type        = number
  default     = 60
}

variable "user_pool_client_id_token_validity" {
  description = "The validity of the id token"
  type        = number
  default     = 60
}

variable "user_pool_client_refresh_token_validity" {
  description = "The validity of the refresh token"
  type        = number
  default     = 30
}

variable "user_pool_client_generate_scret" {
  description = "Whether to generate a client secret"
  type        = bool
  default     = true
}

variable "user_pool_client_explicit_auth_flows" {
  description = "The explicit authentication flows"
  type        = list(string)
  default     = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

variable "user_pool_client_allow_oauth_flows" {
  description = "Whether to allow OAuth flows"
  type        = bool
  default     = true
}

variable "user_pool_client_allowed_oauth_flows" {
  description = "The allowed OAuth flows"
  type        = list(string)
  default     = ["client_credentials"]
}

variable "user_pool_client_allowed_oauth_scopes" {
  description = "The allowed OAuth scopes"
  type        = list(string)
  default     = ["openid", "email", "profile", "aws.cognito.signin.user.admin"]
}

variable "user_pool_client_callback_urls" {
  description = "The callback URLs"
  type        = list(string)
  default     = ["https://localhost/callback"]
}

variable "user_pool_client_logout_urls" {
  description = "The logout URLs"
  type        = list(string)
  default     = ["https://localhost/callback"]
}

## User Pool domain variables
variable "user_pool_domain_name" {
  description = "The domain name"
  type        = string
}

variable "user_pool_domain_certificate_arn" {
  description = "The ARN of the ACM Certificate issued by AWS"
  type        = string
}
