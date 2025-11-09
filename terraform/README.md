# ECS Backend App - Terraform Infrastructure

This repository contains Terraform infrastructure as code for deploying a microservices-based backend application on AWS ECS (Elastic Container Service) with API Gateway, Application Load Balancer, and Cognito authentication.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Internet/Clients                             │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ HTTPS (with Cognito JWT)
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      AWS API Gateway                                 │
│  - REST API with Cognito Authorizer                                 │
│  - Path-based routing to microservices                              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ VPC Link
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            VPC                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              Internal Application Load Balancer               │  │
│  │              - Path-based routing                             │  │
│  │              - Health checks                                  │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
│                           │                                          │
│  ┌────────────────────────┴─────────────────────────────────────┐  │
│  │                    ECS Cluster (Fargate)                      │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │  │
│  │  │   Users      │  │  Products    │  │   Orders     │       │  │
│  │  │   Service    │  │  Service     │  │   Service    │       │  │
│  │  │              │  │              │  │              │       │  │
│  │  │  /users/*    │  │ /products/*  │  │  /orders/*   │       │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘       │  │
│  │                                                                │  │
│  │  - Auto-scaling based on CPU                                  │  │
│  │  - CloudWatch Container Insights                              │  │
│  │  - Private subnets (no direct internet access)                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                    Cognito User Pool                            │  │
│  │  - User authentication                                          │  │
│  │  - JWT token generation                                         │  │
│  └────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
terraform/
├── README.md                          # This file
├── modules/                           # Reusable Terraform modules
│   ├── vpc/                          # VPC with public/private subnets
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── locals.tf
│   ├── alb/                          # Application Load Balancer
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── locals.tf
│   ├── api_gateway/                  # API Gateway REST API
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── locals.tf
│   ├── cognito/                      # Cognito User Pool
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── locals.tf
│   └── ecs/
│       ├── cluster/                  # ECS Cluster
│       │   ├── README.md
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   └── locals.tf
│       └── service/                  # ECS Service (microservice)
│           ├── README.md
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           └── locals.tf
└── envs/                             # Environment-specific configurations
    ├── dev/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── terraform.tfvars
    │   └── provider.tf
    ├── qa/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── terraform.tfvars
    │   └── provider.tf
    └── prod/
        ├── main.tf
        ├── variables.tf
        ├── terraform.tfvars
        └── provider.tf
```

## Modules

### Core Infrastructure Modules

#### 1. VPC Module (`modules/vpc`)
Creates a complete VPC infrastructure with:
- VPC with configurable CIDR block
- 2 public subnets (across 2 AZs)
- 2 private subnets (across 2 AZs)
- Internet Gateway
- Route tables

**Key Outputs:** `vpc_id`, `private_subnets`, `public_subnets`

[Full Documentation](modules/vpc/README.md)

#### 2. ALB Module (`modules/alb`)
Creates an internal Application Load Balancer with:
- Internal ALB in private subnets
- Security group with VPC-scoped access
- Default target group
- HTTP listener (port 80)
- VPC Link for API Gateway integration

**Key Outputs:** `alb_arn`, `alb_dns_name`, `listener_arn`, `alb_vpc_link_id`, `alb_sg_id`

[Full Documentation](modules/alb/README.md)

#### 3. API Gateway Module (`modules/api_gateway`)
Creates a REST API with:
- REST API with Cognito authorization
- Proxy resource for catch-all routing
- VPC Link integration to ALB
- Configurable endpoint type (REGIONAL/EDGE)
- Automatic redeployment on changes

**Key Outputs:** `api_gateway_invoke_url`, `api_gateway_id`, `api_gateway_execution_arn`

[Full Documentation](modules/api_gateway/README.md)

#### 4. Cognito Module (`modules/cognito`)
Creates user authentication with:
- Cognito User Pool
- User Pool Client with OAuth 2.0
- Custom domain for hosted UI
- Configurable password policies
- Token validity configuration

**Key Outputs:** `cognito_user_pool_id`, `cognito_user_pool_arn`, `cognito_user_pool_client_id`

[Full Documentation](modules/cognito/README.md)

### ECS Modules

#### 5. ECS Cluster Module (`modules/ecs/cluster`)
Creates an ECS cluster with:
- Fargate and Fargate Spot capacity providers
- CloudWatch Container Insights
- Configurable capacity provider strategy

**Key Outputs:** `cluster_id`, `cluster_arn`, `cluster_name`

[Full Documentation](modules/ecs/cluster/README.md)

#### 6. ECS Service Module (`modules/ecs/service`)
Creates a microservice with:
- ECS Fargate service
- Task definition with container configuration
- Target group with health checks
- ALB listener rule for path-based routing
- Security group for ECS tasks
- IAM roles (task execution and task role)
- CloudWatch log group
- Optional auto-scaling

**Key Outputs:** `service_arn`, `task_definition_arn`, `target_group_arn`, `security_group_id`

[Full Documentation](modules/ecs/service/README.md)

## Environments

The infrastructure supports three environments:

### Development (`envs/dev`)
- Region: `eu-west-1`
- Project: `rm-ms-api`
- VPC CIDR: `10.0.0.0/16`
- Container Insights: Enabled
- Auto-scaling: Enabled (1-5 tasks)

### QA (`envs/qa`)
- Pre-production testing environment
- Similar configuration to dev with separate resources

### Production (`envs/prod`)
- Production environment
- Enhanced security and monitoring
- Deletion protection enabled
- Higher resource limits

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **AWS CLI** configured with credentials
4. **Docker images** pushed to ECR (or other registry)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd terraform
```

### 2. Configure AWS Credentials

```bash
aws configure
# Or use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-west-1"
```

### 3. Initialize Terraform

```bash
cd envs/dev
terraform init
```

### 4. Review and Customize Variables

Edit `terraform.tfvars`:

```hcl
aws_region   = "eu-west-1"
environment  = "dev"
project_name = "rm-ms-api"

vpc_cidr_block                  = "10.0.0.0/16"
vpc_subnet_public_a_cidr_block  = "10.0.1.0/24"
vpc_subnet_public_b_cidr_block  = "10.0.2.0/24"
vpc_subnet_private_a_cidr_block = "10.0.101.0/24"
vpc_subnet_private_b_cidr_block = "10.0.102.0/24"

# Update with your ECR image URIs
users_service_image = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/users:latest"
```

### 5. Plan the Deployment

```bash
terraform plan
```

### 6. Apply the Configuration

```bash
terraform apply
```

### 7. Get the API Gateway URL

```bash
terraform output
```

## Adding a New Microservice

To add a new microservice (e.g., "products"):

1. **Add the service module** to `envs/dev/main.tf`:

```hcl
module "products_service" {
  source = "../../modules/ecs/service"

  # Global variables
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
  service_name = "products"

  # ECS cluster
  ecs_cluster_id = module.ecs_cluster.cluster_id

  # Networking
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_security_group_id = module.alb.alb_sg_id

  # Load balancing
  alb_listener_arn       = module.alb.listener_arn
  listener_rule_priority = 200  # Must be unique!
  path_pattern           = ["/products", "/products/*"]
  health_check_path      = "/products/health"

  # Container configuration
  container_image  = var.products_service_image
  container_port   = 8080
  container_cpu    = 256
  container_memory = 512

  # Service configuration
  desired_count = 2

  # Auto-scaling
  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 5
  autoscaling_target_cpu   = 70
}
```

2. **Add the variable** to `variables.tf`:

```hcl
variable "products_service_image" {
  description = "Docker image for the products service"
  type        = string
}
```

3. **Add the value** to `terraform.tfvars`:

```hcl
products_service_image = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/products:latest"
```

4. **Apply the changes**:

```bash
terraform apply
```

## Common Operations

### Deploying to a Different Environment

```bash
cd envs/qa
terraform init
terraform plan
terraform apply
```

### Updating a Service Image

1. Update the image tag in `terraform.tfvars`
2. Apply the changes:

```bash
terraform apply -target=module.users_service
```

### Scaling a Service

Update the `desired_count` in the service module and apply:

```bash
terraform apply -target=module.users_service
```

### Viewing Logs

```bash
# Get log group name
terraform output

# View logs
aws logs tail /ecs/rm-ms-api-dev-users --follow
```

### Destroying Resources

```bash
# Destroy specific service
terraform destroy -target=module.users_service

# Destroy entire environment
terraform destroy
```

## Authentication Flow

1. **User Registration/Login**
   - Users authenticate via Cognito User Pool
   - Cognito returns JWT tokens (ID token, Access token, Refresh token)

2. **API Request**
   - Client includes JWT token in Authorization header
   - API Gateway validates token with Cognito
   - Valid requests are forwarded to ALB via VPC Link

3. **Service Access**
   - ALB routes request based on path pattern
   - Request reaches appropriate ECS service
   - Service processes request and returns response

### Example API Call

```bash
# Get token from Cognito
TOKEN=$(aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id <client-id> \
  --auth-parameters USERNAME=user@example.com,PASSWORD=password \
  --query 'AuthenticationResult.IdToken' \
  --output text)

# Call API
curl -H "Authorization: Bearer $TOKEN" \
  https://<api-id>.execute-api.eu-west-1.amazonaws.com/dev/users
```

## Monitoring and Logging

### CloudWatch Container Insights
- Enabled by default on ECS cluster
- Provides metrics for CPU, memory, network, and disk usage
- View in CloudWatch Console under Container Insights

### Service Logs
- Each service has its own CloudWatch log group
- Log group: `/ecs/{project_name}-{environment}-{service_name}`
- Default retention: 30 days

### ALB Metrics
- Target health
- Request count
- Response times
- HTTP status codes

### API Gateway Metrics
- Request count
- Latency
- 4xx/5xx errors
- Integration latency

## Security Best Practices

1. **Network Isolation**
   - ECS tasks run in private subnets
   - ALB is internal (not internet-facing)
   - API Gateway provides public endpoint with authentication

2. **Authentication**
   - All API requests require valid Cognito JWT tokens
   - Token validation at API Gateway level

3. **IAM Roles**
   - Task execution role for pulling images and writing logs
   - Task role for application-specific AWS service access
   - Principle of least privilege

4. **Security Groups**
   - ALB security group allows traffic only from VPC CIDR
   - ECS task security groups allow traffic only from ALB

5. **Secrets Management**
   - Use AWS Secrets Manager or SSM Parameter Store
   - Reference secrets in task definitions
   - Never commit secrets to version control

## Cost Optimization

### Development Environment
- Use Fargate Spot for non-critical workloads
- Set lower desired task counts
- Use smaller task sizes (256 CPU, 512 MB)
- Shorter log retention (7-30 days)

### Production Environment
- Use Fargate for critical workloads
- Enable auto-scaling to handle variable load
- Right-size tasks based on actual usage
- Consider Reserved Capacity for predictable workloads

### Estimated Monthly Costs (Development)

| Service | Cost |
|---------|------|
| VPC | Free |
| ALB | ~$16 |
| VPC Link | ~$7 |
| API Gateway | $3.50 per million requests |
| Cognito | Free (< 50K MAUs) |
| ECS Fargate (2 tasks, 0.25 vCPU, 0.5 GB) | ~$15 |
| CloudWatch Logs (1 GB/month) | ~$0.50 |
| **Total** | **~$42/month + usage** |

## Troubleshooting

### Common Issues

#### 1. Service Tasks Not Starting

**Check:**
- Container image exists and is accessible
- Task execution role has ECR permissions
- Security groups allow necessary traffic
- Subnets have available IP addresses

```bash
aws ecs describe-services --cluster <cluster-name> --services <service-name>
aws ecs describe-tasks --cluster <cluster-name> --tasks <task-arn>
```

#### 2. Health Checks Failing

**Check:**
- Health check path is correct and accessible
- Container is listening on the correct port
- Security group allows traffic from ALB
- Application is responding within timeout period

```bash
aws elbv2 describe-target-health --target-group-arn <tg-arn>
```

#### 3. API Gateway 401 Unauthorized

**Check:**
- JWT token is valid and not expired
- Token is in Authorization header
- Cognito User Pool ARN is correct in authorizer
- User is confirmed in Cognito

#### 4. Cannot Access Service

**Check:**
- API Gateway deployment is current
- VPC Link is in AVAILABLE state
- ALB is healthy
- Path pattern matches request path

### Debug Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster <cluster> --services <service>

# View task logs
aws logs tail /ecs/<project>-<env>-<service> --follow

# Check target health
aws elbv2 describe-target-health --target-group-arn <arn>

# Test API Gateway
curl -v https://<api-id>.execute-api.<region>.amazonaws.com/<stage>/users

# Check VPC Link status
aws apigateway get-vpc-link --vpc-link-id <id>
```

## Maintenance

### Regular Tasks

1. **Update Container Images**
   - Build and push new images to ECR
   - Update image tags in terraform.tfvars
   - Apply changes with Terraform

2. **Review Logs**
   - Check CloudWatch logs for errors
   - Set up CloudWatch alarms for critical metrics

3. **Monitor Costs**
   - Review AWS Cost Explorer
   - Optimize resource usage based on metrics

4. **Security Updates**
   - Keep Terraform providers updated
   - Update base container images
   - Review IAM policies

5. **Backup**
   - Terraform state is critical - use remote backend (S3)
   - Enable versioning on state bucket
   - Regular backups of Cognito user pool

## CI/CD Integration

### Example GitHub Actions Workflow

```yaml
name: Deploy to Dev

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-1
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
      
      - name: Terraform Init
        run: |
          cd terraform/envs/dev
          terraform init
      
      - name: Terraform Plan
        run: |
          cd terraform/envs/dev
          terraform plan
      
      - name: Terraform Apply
        run: |
          cd terraform/envs/dev
          terraform apply -auto-approve
```

## Contributing

1. Create a feature branch
2. Make changes to modules or environments
3. Test in dev environment
4. Submit pull request with description
5. Apply to QA after review
6. Deploy to production after QA validation

## Support

For issues or questions:
1. Check module-specific README files
2. Review troubleshooting section
3. Check AWS service documentation
4. Review Terraform logs

## License

See the LICENSE file in the root of the repository.

## Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
