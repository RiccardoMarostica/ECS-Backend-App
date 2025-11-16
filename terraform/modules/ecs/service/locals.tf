locals {
  service_name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      Service     = var.service_name
      ManagedBy   = "Terraform"
    }
  )

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.container_image
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = var.container_environment_variables
      secrets     = var.container_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.service_name
        }
      }
    }
  ])

  # Validation: CPU and memory combinations for Fargate
  valid_cpu_memory_combinations = {
    256  = [512, 1024, 2048]
    512  = [1024, 2048, 3072, 4096]
    1024 = [for i in range(2048, 8192 + 1, 1024) : i]
    2048 = [for i in range(4096, 16384 + 1, 1024) : i]
    4096 = [for i in range(8192, 30720 + 1, 1024) : i]
  }

  is_valid_cpu_memory = contains(
    lookup(local.valid_cpu_memory_combinations, var.container_cpu, []),
    var.container_memory
  )

  # Validation: Autoscaling min <= max
  is_valid_autoscaling = var.autoscaling_max_capacity >= var.autoscaling_min_capacity

  # Extract LoadBalancer ARN suffix from listener ARN for CloudWatch alarms
  # Listener ARN format: arn:aws:elasticloadbalancing:region:account-id:listener/app/load-balancer-name/load-balancer-id/listener-id
  # We need: app/load-balancer-name/load-balancer-id
  alb_arn_suffix = regex("(app/[^/]+/[a-z0-9]+)", var.alb_listener_arn)[0]
}
