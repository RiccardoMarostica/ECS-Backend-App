# Global variables
variable "aws_region" {
  description = "The AWS Region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Defines the deployment environment (dev, qa, prod)"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone"
  type        = string
}

# API Gateway variables
variable "rest_api_name" {
  description = "The name of the REST API"
  type        = string
}

variable "rest_api_disable_execute_endpoint" {
  description = "Whether clients can invoke the REST API using the default execute-api endpoint"
  type        = bool
  default     = false
}

variable "rest_api_endpoint_ip_address_type" {
  description = "The IP address type that can invoke an API"
  type        = string
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4", "ipv6"], var.rest_api_endpoint_ip_address_type)
    error_message = "The IP address type must be \"ipv4\" or \"ipv6\"."
  }
}

variable "rest_api_endpoint_type" {
  description = "The type of endpoint for the REST API"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["EDGE", "REGIONAL"], var.rest_api_endpoint_type)
    error_message = "The endpoint type must be \"EDGE\", \"REGIONAL\"."
  }
}


# API Gateway - Cognito Authorizer
variable "rest_api_authorizer_name" {
  description = "The name of the authorizer"
  type        = string
}

variable "rest_api_authorizer_type" {
  description = "The type of the authorizer"
  type        = string
  default     = "COGNITO_USER_POOLS"
}

variable "rest_api_authorizer_ttl" {
  description = "The TTL of cached authorizer results"
  type        = number
  default     = 300
}

variable "rest_api_authorizer_cognito_provider" {
  description = "List of the Amazon Cognito user pool ARNs"
  type        = list(string)
  default     = []
}

# API Gateway - Deployment options
variable "rest_api_stage_name" {
  description = "The name of the stage, which is exactly the name of the environment"
  type        = string
}

# API Gateway - Custom domain
variable "rest_api_enable_custom_domain" {
  description = "Whether to create a custom domain name for the API"
  type        = bool
  default     = false
}

variable "rest_api_custom_domain_certificate_arn" {
  description = "The ARN of the ACM certificate to create the custom domain"
  type        = string
  default     = ""
}

variable "rest_api_custom_domain_name" {
  description = "The name of the custom domain"
  type        = string
  default     = ""
}

# ALB parameters
variable "alb_vpc_link_id" {
  description = "The ID of the VPC Link"
  type        = string
}

variable "alb_listener_arn" {
  description = "The ARN of the ALB Listener"
  type        = string
}
