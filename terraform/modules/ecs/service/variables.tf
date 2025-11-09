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

# Service identification
variable "service_name" {
  description = "Name of the microservice (e.g., users, products)"
  type        = string
}

# Networking
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

# IAM
variable "task_role_policy_statements" {
  description = "Custom IAM policy statements for the task role"
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

# Container configuration
variable "container_image" {
  description = "Docker image for the container (e.g., ECR URI)"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the task in MB (512, 1024, 2048, etc.)"
  type        = number
  default     = 512
}

variable "container_environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "Secrets from SSM Parameter Store or Secrets Manager"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
