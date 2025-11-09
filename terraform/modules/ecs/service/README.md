# ECS Service Module

This Terraform module creates a complete ECS service with all necessary components for deploying a containerized microservice. It includes task definitions, IAM roles, security groups, load balancing, CloudWatch logging, and optional auto-scaling.

## Features

- Creates ECS service with Fargate launch type
- Configurable task definition with container specifications
- IAM roles for task execution and application permissions
- Security group with ALB integration
- ALB target group with health checks
- Path-based routing via ALB listener rules
- CloudWatch Logs integration
- Optional CPU-based auto-scaling
- Support for environment variables and secrets
- Comprehensive validation for Fargate CPU/memory combinations

## Architecture

```
API Gateway → ALB → Listener Rule (path-based) → Target Group → ECS Tasks (Private Subnets)
                                                                      ↓
                                                              CloudWatch Logs
```

## Usage

### Basic Example

```hcl
module "users_service" {
  source = "../../modules/ecs/service"

  # Global variables
  aws_region   = "us-east-1"
  environment  = "dev"
  project_name = "myapp"
  service_name = "users"

  # ECS cluster
  ecs_cluster_id = module.ecs_cluster.cluster_id

  # Networking
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_security_group_id = module.alb.alb_sg_id

  # Load balancing
  alb_listener_arn       = module.alb.listener_arn
  listener_rule_priority = 100
  path_pattern           = ["/users", "/users/*"]

  # Container configuration
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/users:latest"
}
```

### Advanced Example with Auto-Scaling

```hcl
module "products_service" {
  source = "../../modules/ecs/service"

  # Global variables
  aws_region   = "us-east-1"
  environment  = "prod"
  project_name = "myapp"
  service_name = "products"

  # ECS cluster
  ecs_cluster_id = module.ecs_cluster.cluster_id

  # Networking
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_security_group_id = module.alb.alb_sg_id

  # Load balancing
  alb_listener_arn       = module.alb.listener_arn
  listener_rule_priority = 200
  path_pattern           = ["/products", "/products/*"]
  health_check_path      = "/products/health"
  health_check_interval  = 30
  health_check_timeout   = 5

  # Container configuration
  container_image  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/products:v1.2.3"
  container_port   = 8080
  container_cpu    = 512
  container_memory = 1024

  container_environment_variables = [
    {
      name  = "LOG_LEVEL"
      value = "info"
    },
    {
      name  = "DATABASE_HOST"
      value = "db.example.com"
    }
  ]

  container_secrets = [
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = "arn:aws:ssm:us-east-1:123456789012:parameter/prod/db/password"
    }
  ]

  # Service configuration
  desired_count                      = 3
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  # Logging
  log_retention_days = 90

  # Auto-scaling
  enable_autoscaling       = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 10
  autoscaling_target_cpu   = 70

  # IAM permissions for accessing S3
  task_role_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      resources = [
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]

  # Additional tags
  tags = {
    Team = "backend"
    Cost = "products-api"
  }
}
```

### High-Performance Example

```hcl
module "analytics_service" {
  source = "../../modules/ecs/service"

  aws_region   = "us-east-1"
  environment  = "prod"
  project_name = "myapp"
  service_name = "analytics"

  ecs_cluster_id = module.ecs_cluster.cluster_id

  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_security_group_id = module.alb.alb_sg_id

  alb_listener_arn       = module.alb.listener_arn
  listener_rule_priority = 300
  path_pattern           = ["/analytics/*"]

  # High-performance configuration
  container_image  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/analytics:latest"
  container_cpu    = 2048
  container_memory = 4096

  desired_count = 5

  enable_autoscaling       = true
  autoscaling_min_capacity = 3
  autoscaling_max_capacity = 20
  autoscaling_target_cpu   = 60
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Resources Created

This module creates the following AWS resources:

- `aws_ecs_task_definition` - Container configuration
- `aws_ecs_service` - Service that manages tasks
- `aws_security_group` - Network security for tasks
- `aws_security_group_rule` (2) - Ingress and egress rules
- `aws_lb_target_group` - ALB target group
- `aws_lb_listener_rule` - Path-based routing rule
- `aws_iam_role` (2) - Task execution and task roles
- `aws_iam_role_policy_attachment` - Managed policy attachment
- `aws_iam_role_policy` (2) - Inline policies
- `aws_cloudwatch_log_group` - Centralized logging
- `aws_appautoscaling_target` - Auto-scaling target (optional)
- `aws_appautoscaling_policy` - Auto-scaling policy (optional)

## Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| aws_region | The AWS Region where resources will be created | `string` |
| environment | Defines the deployment environment (dev, qa, prod) | `string` |
| project_name | The name of the project | `string` |
| service_name | Name of the microservice (e.g., users, products) | `string` |
| ecs_cluster_id | The ID of the ECS cluster | `string` |
| vpc_id | The ID of the VPC | `string` |
| private_subnet_ids | List of private subnet IDs for ECS tasks | `list(string)` |
| alb_security_group_id | Security group ID of the ALB | `string` |
| alb_listener_arn | ARN of the ALB listener | `string` |
| listener_rule_priority | Priority for the ALB listener rule (must be unique) | `number` |
| path_pattern | Path pattern for routing (e.g., /users/*) | `list(string)` |
| container_image | Docker image for the container (e.g., ECR URI) | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| container_port | Port exposed by the container | `number` | `8080` |
| container_cpu | CPU units for the task | `number` | `256` |
| container_memory | Memory for the task in MB | `number` | `512` |
| container_environment_variables | Environment variables for the container | `list(object)` | `[]` |
| container_secrets | Secrets from SSM Parameter Store or Secrets Manager | `list(object)` | `[]` |
| desired_count | Desired number of tasks | `number` | `2` |
| deployment_maximum_percent | Maximum percentage of tasks during deployment | `number` | `200` |
| deployment_minimum_healthy_percent | Minimum healthy percentage during deployment | `number` | `100` |
| health_check_grace_period_seconds | Grace period for health checks after task startup | `number` | `60` |
| health_check_path | Health check path for the target group | `string` | `"/health"` |
| health_check_interval | Health check interval in seconds | `number` | `30` |
| health_check_timeout | Health check timeout in seconds | `number` | `5` |
| health_check_healthy_threshold | Number of consecutive successful health checks | `number` | `2` |
| health_check_unhealthy_threshold | Number of consecutive failed health checks | `number` | `3` |
| log_retention_days | CloudWatch log retention in days | `number` | `30` |
| enable_autoscaling | Enable auto-scaling for the service | `bool` | `false` |
| autoscaling_min_capacity | Minimum number of tasks | `number` | `1` |
| autoscaling_max_capacity | Maximum number of tasks | `number` | `10` |
| autoscaling_target_cpu | Target CPU utilization percentage for auto-scaling | `number` | `70` |
| task_role_policy_statements | Custom IAM policy statements for the task role | `list(object)` | `[]` |
| tags | Additional tags for resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| service_id | ID of the ECS service |
| service_arn | ARN of the ECS service |
| service_name | Name of the ECS service |
| task_definition_arn | ARN of the task definition |
| target_group_arn | ARN of the target group |
| target_group_name | Name of the target group |
| security_group_id | ID of the ECS tasks security group |
| security_group_arn | ARN of the ECS tasks security group |
| task_execution_role_arn | ARN of the task execution IAM role |
| task_role_arn | ARN of the task IAM role |
| log_group_name | Name of the CloudWatch log group |
| log_group_arn | ARN of the CloudWatch log group |

## Naming Convention

Resources are named using the pattern: `{project_name}-{environment}-{service_name}-{resource_type}`

Example: `myapp-dev-users-service`

## Fargate CPU and Memory Combinations

The module validates that CPU and memory combinations are valid for Fargate:

| CPU (units) | Memory (MB) |
|-------------|-------------|
| 256 | 512, 1024, 2048 |
| 512 | 1024, 2048, 3072, 4096 |
| 1024 | 2048, 3072, 4096, 5120, 6144, 7168, 8192 |
| 2048 | 4096, 5120, 6144, 7168, 8192, 9216, 10240, 11264, 12288, 13312, 14336, 15360, 16384 |
| 4096 | 8192, 9216, 10240, ..., 30720 (increments of 1024) |

## IAM Roles

### Task Execution Role

Used by ECS to:
- Pull container images from ECR
- Write logs to CloudWatch
- Retrieve secrets from SSM Parameter Store or Secrets Manager

### Task Role

Used by the application running in the container to:
- Access AWS services (S3, DynamoDB, etc.)
- Custom permissions defined via `task_role_policy_statements`

## Security

### Network Security

- Tasks are deployed in private subnets only
- Security group allows inbound traffic only from ALB
- All outbound traffic is allowed for external API calls

### IAM Security

- Follows principle of least privilege
- Separate roles for execution and application
- Custom policies can be added via variables

## Health Checks

The module configures ALB health checks with the following defaults:

- Path: `/health`
- Interval: 30 seconds
- Timeout: 5 seconds
- Healthy threshold: 2 consecutive successes
- Unhealthy threshold: 3 consecutive failures

Your application must implement the health check endpoint and return HTTP 200 for healthy status.

## Auto-Scaling

When enabled, the module creates a target tracking scaling policy based on CPU utilization:

- Scales out when average CPU exceeds target percentage
- Scales in when average CPU is below target percentage
- Respects min and max capacity constraints
- Uses a 300-second cooldown period

## CloudWatch Logs

Logs are organized using the pattern: `/ecs/{project_name}/{environment}/{service_name}`

Example: `/ecs/myapp/dev/users`

Log streams are prefixed with the service name for easy identification.

## Integration with Other Modules

This service module integrates with:

### VPC Module
```hcl
vpc_id             = module.vpc.vpc_id
private_subnet_ids = module.vpc.private_subnets
```

### ALB Module
```hcl
alb_listener_arn       = module.alb.listener_arn
alb_security_group_id  = module.alb.alb_sg_id
```

### ECS Cluster Module
```hcl
ecs_cluster_id = module.ecs_cluster.cluster_id
```

### API Gateway Module
The API Gateway routes traffic to the ALB, which then routes to ECS services based on path patterns.

## Common Scenarios

### Scenario 1: Simple REST API

```hcl
module "api_service" {
  source = "../../modules/ecs/service"
  
  # ... required variables
  
  container_cpu    = 256
  container_memory = 512
  desired_count    = 2
  path_pattern     = ["/api/*"]
}
```

### Scenario 2: Background Worker (No ALB)

This module is designed for services behind an ALB. For background workers, consider using a separate module or modifying this one to make ALB components optional.

### Scenario 3: Multiple Environments

```hcl
# Development
module "users_service_dev" {
  source = "../../modules/ecs/service"
  environment = "dev"
  desired_count = 1
  enable_autoscaling = false
  log_retention_days = 7
}

# Production
module "users_service_prod" {
  source = "../../modules/ecs/service"
  environment = "prod"
  desired_count = 3
  enable_autoscaling = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 20
  log_retention_days = 90
}
```

### Scenario 4: Service with Database Access

```hcl
module "orders_service" {
  source = "../../modules/ecs/service"
  
  # ... other configuration
  
  container_environment_variables = [
    {
      name  = "DB_HOST"
      value = module.rds.endpoint
    },
    {
      name  = "DB_PORT"
      value = "5432"
    }
  ]
  
  container_secrets = [
    {
      name      = "DB_PASSWORD"
      valueFrom = aws_ssm_parameter.db_password.arn
    }
  ]
  
  task_role_policy_statements = [
    {
      effect = "Allow"
      actions = ["ssm:GetParameter"]
      resources = [aws_ssm_parameter.db_password.arn]
    }
  ]
}
```

## Troubleshooting

### Issue: Tasks fail to start

**Symptom**: ECS service shows tasks starting and stopping repeatedly

**Possible Causes & Solutions**:

1. **Container image not found**
   - Verify the `container_image` URI is correct
   - Ensure the task execution role has ECR pull permissions
   - Check if the image exists in ECR: `aws ecr describe-images --repository-name <repo>`

2. **Invalid CPU/memory combination**
   - Review the Fargate CPU/memory combinations table above
   - Terraform will validate this, but double-check your values

3. **Application crashes on startup**
   - Check CloudWatch Logs: `aws logs tail /ecs/{project}/{env}/{service} --follow`
   - Verify environment variables and secrets are correct
   - Ensure health check grace period is sufficient

### Issue: Health checks failing

**Symptom**: Target group shows unhealthy targets

**Solutions**:
- Verify your application implements the health check endpoint
- Check the health check path matches your application's endpoint
- Ensure the application listens on the correct port
- Increase `health_check_grace_period_seconds` if startup is slow
- Review application logs for errors

### Issue: Cannot reach service through ALB

**Symptom**: Requests to the service return 503 or timeout

**Solutions**:
- Verify the listener rule priority doesn't conflict with other services
- Check the path pattern matches your request path
- Ensure target group has healthy targets
- Verify security group rules allow traffic from ALB to tasks
- Check ALB security group allows inbound traffic

### Issue: Auto-scaling not working

**Symptom**: Service doesn't scale despite high CPU

**Solutions**:
- Verify `enable_autoscaling` is set to `true`
- Check CloudWatch metrics for CPU utilization
- Ensure `autoscaling_max_capacity` is greater than `desired_count`
- Review CloudWatch alarms created by the scaling policy
- Wait for the cooldown period (300 seconds) to complete

### Issue: Permission denied errors in logs

**Symptom**: Application logs show AWS permission errors

**Solutions**:
- Add required permissions to `task_role_policy_statements`
- Verify IAM policy syntax is correct
- Check the resource ARNs in the policy
- Use AWS IAM Policy Simulator to test permissions

### Issue: Secrets not loading

**Symptom**: Application can't access secrets

**Solutions**:
- Verify the `valueFrom` ARN is correct
- Ensure task execution role has permissions to read the secret
- Check if the secret exists: `aws ssm get-parameter --name <name>`
- For Secrets Manager: Use the full ARN, not just the name

### Issue: High costs

**Symptom**: ECS costs are higher than expected

**Solutions**:
- Review `desired_count` and auto-scaling settings
- Consider using smaller CPU/memory combinations
- Use Fargate Spot for non-critical services (configure at cluster level)
- Reduce `log_retention_days` for dev environments
- Disable Container Insights in non-production environments

## Validation Rules

The module includes built-in validation for:

- Listener rule priority: Must be between 1 and 50,000
- Path patterns: Must start with `/`
- Health check interval: 5-300 seconds
- Health check timeout: 2-120 seconds
- Health check thresholds: 2-10
- CPU values: Must be 256, 512, 1024, 2048, or 4096
- Memory values: Must be valid for the selected CPU
- Auto-scaling: Max capacity must be >= min capacity

## Best Practices

1. **Use descriptive service names**: Choose names that clearly identify the service purpose
2. **Implement health checks**: Always provide a `/health` endpoint that returns 200 when healthy
3. **Use secrets for sensitive data**: Never put passwords or API keys in environment variables
4. **Enable auto-scaling in production**: Protect against traffic spikes
5. **Set appropriate log retention**: Balance cost and compliance requirements
6. **Use unique listener priorities**: Document priority ranges for different service types
7. **Tag resources**: Use the `tags` variable to add cost allocation and ownership tags
8. **Right-size resources**: Start small and scale up based on actual usage
9. **Monitor CloudWatch metrics**: Set up alarms for CPU, memory, and error rates
10. **Use blue/green deployments**: Set `deployment_maximum_percent` to 200 for zero-downtime updates

## Examples

See `terraform/envs/dev/main.tf` for a complete working example of how this module is used in practice.

## License

This module is part of the project infrastructure and follows the project's license terms.
