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
}
