# Application Load Balancer (ALB) Module

This Terraform module creates an internal Application Load Balancer (ALB) with associated security groups, target groups, and API Gateway VPC Link for routing traffic to ECS services within a VPC.

## Features

- Internal Application Load Balancer for private network traffic
- Security group with VPC-scoped ingress rules
- Default target group for HTTP traffic
- HTTP listener on port 80
- API Gateway VPC Link for integration with API Gateway
- Configurable deletion protection

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Resources Created

This module creates the following AWS resources:

- `aws_lb` - Internal Application Load Balancer
- `aws_security_group` - Security group for ALB
- `aws_lb_target_group` - Default target group
- `aws_lb_listener` - HTTP listener on port 80
- `aws_api_gateway_vpc_link` - VPC Link for API Gateway integration

## Usage

### Basic Example

```hcl
module "alb" {
  source = "./modules/alb"

  aws_region      = "us-east-1"
  environment     = "dev"
  project_name    = "myapp"
  vpc_id          = "vpc-12345678"
  vpc_cidr_block  = "10.0.0.0/16"
  vpc_private_subnets = [
    "subnet-12345678",
    "subnet-87654321"
  ]
}
```

### Production Example with Deletion Protection

```hcl
module "alb" {
  source = "./modules/alb"

  aws_region               = "us-east-1"
  environment              = "prod"
  project_name             = "myapp"
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr_block           = module.vpc.vpc_cidr_block
  vpc_private_subnets      = module.vpc.private_subnets
  alb_deletion_procection  = true
}
```

### Integration with VPC Module

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  aws_region   = "us-east-1"
  environment  = "dev"
  project_name = "myapp"
}

module "alb" {
  source = "./modules/alb"

  aws_region          = "us-east-1"
  environment         = "dev"
  project_name        = "myapp"
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.vpc_cidr_block
  vpc_private_subnets = module.vpc.private_subnets
}
```

### Integration with ECS Service Module

```hcl
module "alb" {
  source = "./modules/alb"

  aws_region          = "us-east-1"
  environment         = "dev"
  project_name        = "myapp"
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.vpc_cidr_block
  vpc_private_subnets = module.vpc.private_subnets
}

module "ecs_service" {
  source = "./modules/ecs/service"

  # ... other variables ...
  alb_listener_arn = module.alb.listener_arn
  alb_sg_id        = module.alb.alb_sg_id
}
```

### Integration with API Gateway Module

```hcl
module "alb" {
  source = "./modules/alb"

  aws_region          = "us-east-1"
  environment         = "dev"
  project_name        = "myapp"
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.vpc_cidr_block
  vpc_private_subnets = module.vpc.private_subnets
}

module "api_gateway" {
  source = "./modules/api_gateway"

  # ... other variables ...
  alb_vpc_link_id = module.alb.alb_vpc_link_id
  alb_dns_name    = module.alb.alb_dns_name
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| aws_region | The AWS Region where resources will be created | `string` |
| environment | Defines the deployment environment (development, qa, prod) | `string` |
| project_name | The name of the project | `string` |
| vpc_id | The ID of the VPC where resources will be created | `string` |
| vpc_cidr_block | The CIDR block of the VPC | `string` |
| vpc_private_subnets | A list of private subnets inside the VPC | `list(string)` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| alb_deletion_procection | Whether the ALB can be deleted or not | `bool` | `false` |

## Outputs

| Name | Description |
|------|-------------|
| alb_id | The ID of the ALB |
| alb_arn | The ARN of the Application Load Balancer |
| alb_dns_name | The DNS name of the ALB |
| listener_arn | The ARN of the HTTP listener |
| alb_sg_id | The ID of the ALB Security Group |
| alb_sg_arn | The ARN of the ALB Security Group |
| alb_vpc_link_id | The ID of the ALB VPC Link |
| alb_vpc_link_arn | The ARN of the ALB VPC Link |

## Security

### Security Group Rules

The module creates a security group with the following rules:

**Ingress:**
- Port 80 (HTTP) - Allowed from VPC CIDR block
- Port 443 (HTTPS) - Allowed from VPC CIDR block

**Egress:**
- All traffic allowed to 0.0.0.0/0

### Best Practices

1. **Internal ALB**: This module creates an internal ALB that is not accessible from the internet
2. **VPC-Scoped Access**: Ingress rules are limited to the VPC CIDR block
3. **Deletion Protection**: Enable `alb_deletion_procection = true` for production environments
4. **Private Subnets**: Always deploy the ALB in private subnets for enhanced security

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                         VPC                              │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │              API Gateway                        │    │
│  └──────────────────┬─────────────────────────────┘    │
│                     │                                    │
│                     │ VPC Link                          │
│                     ▼                                    │
│  ┌────────────────────────────────────────────────┐    │
│  │         Internal ALB (Port 80/443)             │    │
│  │         Security Group: VPC CIDR only          │    │
│  └──────────────────┬─────────────────────────────┘    │
│                     │                                    │
│                     │ Target Groups                     │
│                     ▼                                    │
│  ┌────────────────────────────────────────────────┐    │
│  │            ECS Services (Tasks)                 │    │
│  │         Running in Private Subnets              │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Common Issues

#### 1. ALB Creation Fails - Insufficient Subnets

**Error:**
```
Error: error creating LB: ValidationError: At least two subnets in two different Availability Zones must be specified
```

**Solution:**
Ensure you provide at least 2 private subnets in different availability zones:

```hcl
vpc_private_subnets = [
  "subnet-12345678",  # us-east-1a
  "subnet-87654321"   # us-east-1b
]
```

#### 2. Target Group Health Checks Failing

**Symptoms:**
- Targets show as unhealthy in the target group
- Services cannot receive traffic

**Solution:**
1. Verify security group rules allow traffic from ALB to ECS tasks
2. Check that ECS tasks are listening on the correct port (80)
3. Ensure health check path is accessible on the service

```hcl
# In your ECS service module
ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [module.alb.alb_sg_id]
}
```

#### 3. VPC Link Creation Timeout

**Error:**
```
Error: error waiting for API Gateway VPC Link creation: timeout while waiting for state to become 'AVAILABLE'
```

**Solution:**
- VPC Link creation can take 5-10 minutes
- Verify the ALB is in a healthy state before creating VPC Link
- Check that the ALB ARN is correct
- Ensure proper IAM permissions for API Gateway to access the ALB

#### 4. Cannot Delete ALB - Deletion Protection Enabled

**Error:**
```
Error: error deleting LB: OperationNotPermitted: Load balancer cannot be deleted because deletion protection is enabled
```

**Solution:**
Either:
1. Set `alb_deletion_procection = false` and run `terraform apply` first
2. Manually disable deletion protection in AWS Console before destroying

#### 5. Security Group Rules Not Working

**Symptoms:**
- Cannot reach ALB from within VPC
- Connection timeouts

**Solution:**
1. Verify `vpc_cidr_block` matches your actual VPC CIDR
2. Check Network ACLs aren't blocking traffic
3. Ensure route tables are properly configured
4. Verify the ALB is in the correct subnets

```bash
# Check ALB status
aws elbv2 describe-load-balancers --names <project>-<env>-alb

# Check target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

#### 6. Module Integration Issues

**Problem:** Outputs not available when integrating with other modules

**Solution:**
Ensure proper dependency chain using `depends_on` if needed:

```hcl
module "ecs_service" {
  source = "./modules/ecs/service"
  
  # ... other variables ...
  alb_listener_arn = module.alb.listener_arn
  
  depends_on = [module.alb]
}
```

## Limitations

1. **HTTP Only**: Currently only supports HTTP listener on port 80 (no HTTPS/SSL)
2. **Single Listener**: Only one default listener is created
3. **Internal Only**: ALB is always internal (not internet-facing)
4. **Default Target Group**: Creates a default target group that may not be used if services create their own

## Future Enhancements

- Add support for HTTPS listeners with ACM certificates
- Support for multiple listeners
- Configurable health check parameters
- Support for WAF integration
- Access logging configuration
- Connection draining settings

## Notes

- **Typo in Variable Name**: The variable `alb_deletion_procection` has a typo (should be "protection"). This is maintained for backward compatibility.
- **Target Type**: The default target group uses `target_type = "ip"` which is suitable for ECS Fargate tasks.
- **Naming Convention**: All resources follow the pattern `{project_name}-{environment}-{resource_type}`

## License

See the LICENSE file in the root of the repository.
