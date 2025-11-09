#####
# ECS SERVICE - CloudWatch Log Group
# This creates a log group for the ECS service
# Centralized logging for the ECS service
#######
# Create a CloudWatch Log Group for the ECS service
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.project_name}/${var.environment}/${var.service_name}"
  retention_in_days = var.log_retention_days
}


#####
# ECS SERVICE - Task Execution IAM Role
# This creates an IAM role for the ECS task execution
# This role is used by the ECS task to pull container images and write logs to CloudWatch
#######
# This role is used by ECS to pull container images and write logs
resource "aws_iam_role" "task_execution" {
  name = "${local.service_name_prefix}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "task_execution_policy" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Inline policy for ECR image pull and CloudWatch Logs write permissions
resource "aws_iam_role_policy" "task_execution_inline" {
  name = "${local.service_name_prefix}-task-execution-inline-policy"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/ecs/${var.project_name}/${var.environment}/${var.service_name}:*"
      }
    ]
  })
}


#####
# ECS SERVICE - Task IAM Role
# This creates an IAM role for the ECS task
# This role is used by the ECS task to access AWS resource
#######
# This role is used by the application running in the container
resource "aws_iam_role" "task" {
  name = "${local.service_name_prefix}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Custom policy for task role based on variable input
resource "aws_iam_role_policy" "task_custom" {
  count = length(var.task_role_policy_statements) > 0 ? 1 : 0
  name  = "${local.service_name_prefix}-task-custom-policy"
  role  = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.task_role_policy_statements : {
        Effect   = statement.effect
        Action   = statement.actions
        Resource = statement.resources
      }
    ]
  })
}


#####
# ECS SERVICE - Security Group
# This creates a security group for the ECS tasks
# Allows inbound traffic from ALB and all outbound traffic
#######
resource "aws_security_group" "ecs_tasks" {
  name        = "${local.service_name_prefix}-ecs-sg"
  description = "Security group for ${var.service_name} ECS tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.service_name_prefix}-ecs-sg"
  }
}

# Ingress rule: Allow traffic from ALB security group on container port
resource "aws_security_group_rule" "ecs_tasks_ingress_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = var.alb_security_group_id
  security_group_id        = aws_security_group.ecs_tasks.id
  description              = "Allow inbound traffic from ALB on container port"
}

# Egress rule: Allow all outbound traffic
resource "aws_security_group_rule" "ecs_tasks_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_tasks.id
  description       = "Allow all outbound traffic"
}


#####
# ECS SERVICE - Task Definition
# This creates the task definition for the ECS service
# Defines the container configuration, CPU, memory, and IAM roles
#######
resource "aws_ecs_task_definition" "main" {
  family                   = local.service_name_prefix
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions    = local.container_definitions

  lifecycle {
    precondition {
      condition     = local.is_valid_cpu_memory
      error_message = <<-EOT
        Invalid CPU and memory combination for Fargate. Valid combinations:
        - CPU 256: Memory 512, 1024, 2048
        - CPU 512: Memory 1024, 2048, 3072, 4096
        - CPU 1024: Memory 2048-8192 (in 1024 MB increments)
        - CPU 2048: Memory 4096-16384 (in 1024 MB increments)
        - CPU 4096: Memory 8192-30720 (in 1024 MB increments)
        Current values: CPU ${var.container_cpu}, Memory ${var.container_memory}
      EOT
    }
  }
}


#####
# ECS SERVICE - ALB Target Group
# This creates a target group for the ECS service
# Routes traffic from ALB to ECS tasks with health checks
#######
resource "aws_lb_target_group" "main" {
  name        = "${local.service_name_prefix}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = "200"
  }

  tags = {
    Name = "${local.service_name_prefix}-tg"
  }
}


#####
# ECS SERVICE - ALB Listener Rule
# This creates a listener rule for path-based routing
# Routes requests matching the path pattern to the target group
#######
resource "aws_lb_listener_rule" "main" {
  listener_arn = var.alb_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = var.path_pattern
    }
  }

  tags = {
    Name = "${local.service_name_prefix}-listener-rule"
  }
}


#####
# ECS SERVICE - Service Resource
# This creates the ECS service that manages running tasks
# Configures Fargate launch type, networking, load balancing, and deployment settings
#######
resource "aws_ecs_service" "main" {
  name            = "${local.service_name_prefix}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  # Ensure listener rule is created before the service
  depends_on = [aws_lb_listener_rule.main]

  tags = {
    Name = "${local.service_name_prefix}-service"
  }
}


#####
# ECS SERVICE - Auto Scaling
# This creates auto-scaling configuration for the ECS service
# Scales tasks based on CPU utilization when enabled
#######
# Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${split("/", var.ecs_cluster_id)[1]}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    precondition {
      condition     = local.is_valid_autoscaling
      error_message = "The autoscaling_max_capacity (${var.autoscaling_max_capacity}) must be greater than or equal to autoscaling_min_capacity (${var.autoscaling_min_capacity})."
    }
  }
}

# Target Tracking Scaling Policy for CPU Utilization
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${local.service_name_prefix}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.autoscaling_target_cpu
  }
}
