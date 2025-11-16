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

# ECS cluster
variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
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

# Load balancing
variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "listener_rule_priority" {
  description = "Priority for the ALB listener rule (must be unique)"
  type        = number

  validation {
    condition     = var.listener_rule_priority > 0 && var.listener_rule_priority <= 50000
    error_message = "The listener_rule_priority must be a positive integer between 1 and 50000."
  }
}

variable "path_pattern" {
  description = "Path pattern for routing (e.g., /users/*)"
  type        = list(string)

  validation {
    condition     = length(var.path_pattern) > 0 && alltrue([for p in var.path_pattern : can(regex("^/.*", p))])
    error_message = "The path_pattern must be a non-empty list and each pattern must start with a forward slash (/)."
  }
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "The health_check_interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "The health_check_timeout must be between 2 and 120 seconds."
  }
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2

  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "The health_check_healthy_threshold must be between 2 and 10."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "The health_check_unhealthy_threshold must be between 2 and 10."
  }
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

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.container_cpu)
    error_message = "The container_cpu must be one of the following valid Fargate values: 256, 512, 1024, 2048, 4096."
  }
}

variable "container_memory" {
  description = "Memory for the task in MB (512, 1024, 2048, etc.)"
  type        = number
  default     = 512

  validation {
    condition     = var.container_memory >= 512 && var.container_memory <= 30720
    error_message = "The container_memory must be between 512 and 30720 MB."
  }
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

# Service configuration
variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percentage during deployment"
  type        = number
  default     = 100
}

variable "health_check_grace_period_seconds" {
  description = "Grace period for health checks after task startup"
  type        = number
  default     = 60
}

# Auto-scaling
variable "enable_autoscaling" {
  description = "Enable auto-scaling for the service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1

  validation {
    condition     = var.autoscaling_min_capacity >= 1
    error_message = "The autoscaling_min_capacity must be at least 1."
  }
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10

  validation {
    condition     = var.autoscaling_max_capacity >= 1
    error_message = "The autoscaling_max_capacity must be at least 1."
  }
}

variable "autoscaling_target_cpu" {
  description = "Target CPU utilization percentage for auto-scaling"
  type        = number
  default     = 70
}

# CloudWatch Alarms
variable "enable_unhealthy_host_alarm" {
  description = "Enable CloudWatch alarm for unhealthy hosts"
  type        = bool
  default     = true
}

variable "unhealthy_host_threshold" {
  description = "Number of unhealthy hosts to trigger alarm"
  type        = number
  default     = 1
}

variable "unhealthy_host_evaluation_periods" {
  description = "Number of periods to evaluate for unhealthy hosts"
  type        = number
  default     = 2
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications (optional)"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
