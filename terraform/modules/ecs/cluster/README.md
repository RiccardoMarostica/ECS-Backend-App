# ECS Cluster Module

This Terraform module creates an AWS ECS (Elastic Container Service) cluster with Fargate capacity providers. The cluster serves as a logical grouping for ECS services and tasks, enabling containerized microservices deployment.

## Features

- Creates an ECS cluster with configurable name based on project and environment
- Supports Fargate and Fargate Spot capacity providers for serverless container execution
- Optional CloudWatch Container Insights for enhanced monitoring
- Configurable capacity provider strategy for cost optimization
- Consistent naming conventions and tagging

## Usage

### Basic Example

```hcl
module "ecs_cluster" {
  source = "../../modules/ecs/cluster"

  aws_region   = "us-east-1"
  environment  = "dev"
  project_name = "myapp"
}
```

### Advanced Example with Custom Configuration

```hcl
module "ecs_cluster" {
  source = "../../modules/ecs/cluster"

  aws_region   = "us-east-1"
  environment  = "prod"
  project_name = "myapp"

  # Enable Container Insights for detailed metrics
  enable_container_insights = true

  # Use both Fargate and Fargate Spot
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # Custom capacity provider strategy
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
      base              = 0
    },
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]
}
```

### Production Example with Fargate Only

```hcl
module "ecs_cluster" {
  source = "../../modules/ecs/cluster"

  aws_region   = "us-east-1"
  environment  = "prod"
  project_name = "myapp"

  # Production: Use only Fargate for reliability
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]

  enable_container_insights = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Resources Created

This module creates the following AWS resources:

- `aws_ecs_cluster` - The ECS cluster
- `aws_ecs_cluster_capacity_providers` - Capacity provider configuration

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | The AWS Region where resources will be created | `string` | n/a | yes |
| environment | Defines the deployment environment (dev, qa, prod) | `string` | n/a | yes |
| project_name | The name of the project | `string` | n/a | yes |
| enable_container_insights | Enable CloudWatch Container Insights for the cluster | `bool` | `true` | no |
| capacity_providers | List of capacity providers for the cluster | `list(string)` | `["FARGATE", "FARGATE_SPOT"]` | no |
| default_capacity_provider_strategy | Default capacity provider strategy for the cluster | `list(object)` | See below | no |

### Default Capacity Provider Strategy

```hcl
[
  {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the ECS cluster |
| cluster_arn | The ARN of the ECS cluster |
| cluster_name | The name of the ECS cluster |

## Naming Convention

Resources are named using the pattern: `{project_name}-{environment}-cluster`

Example: `myapp-dev-cluster`

## CloudWatch Container Insights

When `enable_container_insights` is set to `true`, the cluster will collect and aggregate metrics for:

- CPU utilization
- Memory utilization
- Network performance
- Disk I/O
- Task and service-level metrics

These metrics are available in CloudWatch and can be used for monitoring, alerting, and auto-scaling decisions.

## Capacity Providers

### Fargate vs Fargate Spot

- **FARGATE**: Standard Fargate capacity with guaranteed availability
- **FARGATE_SPOT**: Spot capacity at up to 70% discount, but can be interrupted

### Capacity Provider Strategy

The strategy determines how tasks are distributed across capacity providers:

- `base`: Minimum number of tasks to run on this provider
- `weight`: Relative percentage of tasks beyond the base

Example: 80% Spot, 20% Fargate with minimum 2 on Fargate:
```hcl
default_capacity_provider_strategy = [
  {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 2
  },
  {
    capacity_provider = "FARGATE_SPOT"
    weight            = 4
    base              = 0
  }
]
```

## Integration with Other Modules

This cluster module is designed to work with the ECS service module:

```hcl
# Create cluster
module "ecs_cluster" {
  source = "../../modules/ecs/cluster"
  # ... configuration
}

# Deploy services to the cluster
module "users_service" {
  source = "../../modules/ecs/service"
  
  ecs_cluster_id = module.ecs_cluster.cluster_id
  # ... other configuration
}
```

## Troubleshooting

### Issue: Cluster creation fails

**Symptom**: Terraform fails to create the cluster

**Solution**: 
- Verify AWS credentials and permissions
- Ensure the IAM user/role has `ecs:CreateCluster` permission
- Check if a cluster with the same name already exists

### Issue: Container Insights not showing metrics

**Symptom**: No metrics appear in CloudWatch Container Insights

**Solution**:
- Verify `enable_container_insights` is set to `true`
- Wait 5-10 minutes for metrics to appear
- Ensure tasks are running in the cluster
- Check CloudWatch Logs for any errors

### Issue: Capacity provider not available

**Symptom**: Error about capacity provider not being available

**Solution**:
- Verify the capacity provider name is correct (case-sensitive)
- Ensure Fargate is available in your region
- Check AWS service health dashboard

## Cost Optimization

1. **Use Fargate Spot for non-critical workloads**: Save up to 70% on compute costs
2. **Disable Container Insights in dev environments**: Reduces CloudWatch costs
3. **Right-size your services**: Use the smallest CPU/memory combination that meets your needs

## Examples

See the `terraform/envs/dev/main.tf` file for a complete working example of how this module is used in practice.

## License

This module is part of the project infrastructure and follows the project's license terms.
