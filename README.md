# ECS Backend App

A production-ready, cloud-native microservices backend infrastructure built on AWS ECS (Elastic Container Service) with API Gateway, Application Load Balancer, and Cognito authentication.

## Overview

This project provides a complete, scalable infrastructure for deploying microservices-based backend applications on AWS. It combines modern cloud architecture patterns with infrastructure as code (Terraform) to create a secure, highly available, and cost-effective platform for running containerized applications.

### Key Features

- **Microservices Architecture**: Deploy multiple independent services with isolated resources
- **Serverless Compute**: AWS Fargate eliminates server management overhead
- **API Gateway Integration**: Single entry point with built-in authentication and routing
- **User Authentication**: Cognito User Pools for secure user management
- **Auto-scaling**: Automatic scaling based on CPU utilization
- **High Availability**: Multi-AZ deployment for fault tolerance
- **Infrastructure as Code**: Fully automated infrastructure provisioning with Terraform
- **Environment Isolation**: Separate dev, qa, and production environments

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Internet/Clients                            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ HTTPS + JWT Authentication
                           ▼
                  ┌─────────────────────┐
                  │   AWS API Gateway   │
                  │  - Cognito Auth     │
                  │  - Rate Limiting    │
                  └──────────┬──────────┘
                             │
                             │ VPC Link
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                          AWS VPC                                 │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │         Internal Application Load Balancer             │    │
│  │         - Path-based routing                           │    │
│  │         - Health checks                                │    │
│  └──────────────────────┬─────────────────────────────────┘    │
│                         │                                        │
│  ┌──────────────────────┴─────────────────────────────────┐    │
│  │              ECS Cluster (Fargate)                      │    │
│  │                                                          │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐             │    │
│  │  │  Users   │  │ Products │  │  Orders  │             │    │
│  │  │ Service  │  │ Service  │  │ Service  │   + More    │    │
│  │  └──────────┘  └──────────┘  └──────────┘             │    │
│  │                                                          │    │
│  │  - Auto-scaling                                         │    │
│  │  - CloudWatch monitoring                                │    │
│  │  - Private subnets                                      │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
ECS-Backend-App/
├── terraform/              # Infrastructure as Code
│   ├── modules/           # Reusable Terraform modules
│   │   ├── vpc/          # Network infrastructure
│   │   ├── alb/          # Application Load Balancer
│   │   ├── api_gateway/  # API Gateway configuration
│   │   ├── cognito/      # User authentication
│   │   └── ecs/          # ECS cluster and services
│   └── envs/             # Environment-specific configs
│       ├── dev/          # Development environment
│       ├── qa/           # QA/staging environment
│       └── prod/         # Production environment
│
├── microservices/         # Application code (services)
│   ├── users/            # User management service
│   ├── products/         # Product catalog service
│   ├── orders/           # Order processing service
│   └── ...               # Additional services
│
├── README.md             # This file
└── LICENSE
```

## Repository Folders

### 📁 `terraform/` - Infrastructure as Code

The `terraform/` folder contains all infrastructure definitions using Terraform. This is where you define and manage your AWS resources.

**Purpose:**
- Provision and manage AWS infrastructure
- Create VPC, subnets, security groups
- Deploy ECS clusters and services
- Configure API Gateway and Cognito
- Manage multiple environments (dev, qa, prod)

**Key Components:**
- **Modules**: Reusable infrastructure components (VPC, ALB, ECS, etc.)
- **Environments**: Environment-specific configurations and variable values
- **State Management**: Terraform state for tracking infrastructure

**When to use:**
- Setting up new environments
- Adding new microservices
- Modifying infrastructure configuration
- Scaling resources
- Updating security policies

[📖 Full Terraform Documentation](terraform/README.md)

### 📁 `microservices/` - Application Code

The `microservices/` folder contains the actual application code for each microservice.

**Purpose:**
- House individual microservice applications
- Each service is independently deployable
- Services communicate via HTTP/REST APIs
- Each service has its own Docker container

**Typical Service Structure:**
```
microservices/users/
├── src/                  # Application source code
├── tests/                # Unit and integration tests
├── Dockerfile            # Container definition
├── requirements.txt      # Dependencies (Python)
├── package.json          # Dependencies (Node.js)
└── README.md            # Service-specific documentation
```

**When to use:**
- Developing new features
- Writing business logic
- Creating API endpoints
- Adding tests
- Building Docker images

## Getting Started

### Prerequisites

- **AWS Account** with appropriate permissions
- **Terraform** >= 1.0 ([Install](https://www.terraform.io/downloads))
- **AWS CLI** configured ([Install](https://aws.amazon.com/cli/))
- **Docker** for building container images ([Install](https://docs.docker.com/get-docker/))
- **Git** for version control

### Quick Start

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ECS-Backend-App.git
cd ECS-Backend-App
```

#### 2. Deploy Infrastructure

```bash
cd terraform/envs/dev
terraform init
terraform plan
terraform apply
```

This will create:
- VPC with public and private subnets
- Internal Application Load Balancer
- ECS Cluster
- API Gateway with Cognito authentication
- All necessary security groups and IAM roles

#### 3. Build and Deploy a Microservice

```bash
# Build Docker image
cd microservices/users
docker build -t users-service .

# Tag and push to ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com
docker tag users-service:latest <account-id>.dkr.ecr.eu-west-1.amazonaws.com/users:latest
docker push <account-id>.dkr.ecr.eu-west-1.amazonaws.com/users:latest

# Update Terraform with new image
cd ../../../terraform/envs/dev
# Edit terraform.tfvars with new image URI
terraform apply
```

#### 4. Test the API

```bash
# Get API Gateway URL
terraform output api_gateway_invoke_url

# Authenticate with Cognito
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id <client-id> \
  --auth-parameters USERNAME=user@example.com,PASSWORD=password

# Call API with token
curl -H "Authorization: Bearer <token>" \
  https://<api-id>.execute-api.eu-west-1.amazonaws.com/dev/users
```

## Project Goals

### Primary Objectives

1. **Scalability**: Handle variable load with automatic scaling
2. **Reliability**: Multi-AZ deployment with health checks and auto-recovery
3. **Security**: Authentication, authorization, and network isolation
4. **Cost Efficiency**: Pay only for resources used, optimize with Fargate Spot
5. **Developer Productivity**: Easy to add new services and deploy updates
6. **Maintainability**: Infrastructure as code for reproducible deployments

### Use Cases

This infrastructure is ideal for:

- **SaaS Applications**: Multi-tenant backend services
- **Mobile App Backends**: RESTful APIs for mobile applications
- **Microservices Migration**: Moving from monolith to microservices
- **API-First Development**: Building API-driven applications
- **Startup MVPs**: Quick deployment with production-ready infrastructure

## Technology Stack

### Infrastructure
- **AWS ECS (Fargate)**: Serverless container orchestration
- **AWS API Gateway**: API management and routing
- **AWS Cognito**: User authentication and authorization
- **Application Load Balancer**: Layer 7 load balancing
- **AWS VPC**: Network isolation and security
- **Terraform**: Infrastructure as code

### Monitoring & Logging
- **CloudWatch Container Insights**: Container metrics
- **CloudWatch Logs**: Centralized logging
- **CloudWatch Alarms**: Alerting and notifications

### Security
- **IAM Roles**: Fine-grained access control
- **Security Groups**: Network-level security
- **Cognito User Pools**: User authentication
- **VPC Private Subnets**: Network isolation

## Development Workflow

### Adding a New Microservice

1. **Create Service Code** in `microservices/<service-name>/`
2. **Build Docker Image** and push to ECR
3. **Add Terraform Module** in `terraform/envs/<env>/main.tf`
4. **Configure Variables** in `terraform.tfvars`
5. **Deploy** with `terraform apply`

### Updating a Service

1. **Make Code Changes** in `microservices/<service-name>/`
2. **Build New Image** with updated tag
3. **Push to ECR**
4. **Update Image Tag** in `terraform.tfvars`
5. **Deploy** with `terraform apply`

### Environment Promotion

```
Development → QA → Production
```

1. Test in `dev` environment
2. Promote to `qa` for validation
3. Deploy to `prod` after approval

## Monitoring and Operations

### Key Metrics

- **Service Health**: Target group health checks
- **CPU/Memory**: Container resource utilization
- **Request Rate**: API Gateway request count
- **Latency**: Response times at API Gateway and ALB
- **Error Rate**: 4xx and 5xx errors

### Accessing Logs

```bash
# View service logs
aws logs tail /ecs/rm-ms-api-dev-users --follow

# View all log groups
aws logs describe-log-groups --log-group-name-prefix /ecs/
```

### Scaling

Auto-scaling is configured based on CPU utilization:
- **Scale Up**: When CPU > 70% for 2 minutes
- **Scale Down**: When CPU < 30% for 5 minutes
- **Limits**: Min 1 task, Max 5 tasks (configurable)

## Cost Estimation

### Development Environment (~$50/month)

| Service | Monthly Cost |
|---------|--------------|
| VPC & Networking | Free |
| Application Load Balancer | ~$16 |
| VPC Link | ~$7 |
| ECS Fargate (2 tasks) | ~$15 |
| API Gateway | ~$3.50 per million requests |
| Cognito | Free (< 50K users) |
| CloudWatch Logs | ~$0.50 |
| **Total** | **~$42 + usage** |

### Production Environment (~$200-500/month)

Depends on:
- Number of services
- Task count and size
- Request volume
- Data transfer

## Security Best Practices

✅ **Implemented:**
- Private subnets for ECS tasks
- Security groups with least privilege
- IAM roles with minimal permissions
- Cognito authentication on all endpoints
- VPC Link for private ALB access

🔒 **Recommended:**
- Enable AWS WAF on API Gateway
- Use AWS Secrets Manager for sensitive data
- Enable VPC Flow Logs
- Implement rate limiting
- Regular security audits

## Troubleshooting

### Common Issues

**Service won't start:**
- Check CloudWatch logs for errors
- Verify ECR image exists and is accessible
- Check security group rules
- Verify IAM role permissions

**Health checks failing:**
- Verify health check path is correct
- Check container is listening on correct port
- Review security group rules
- Check application logs

**API returns 401:**
- Verify Cognito token is valid
- Check token is in Authorization header
- Verify Cognito User Pool configuration

[Full troubleshooting guide](terraform/README.md#troubleshooting)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Documentation

- [Terraform Infrastructure Guide](terraform/README.md)
- [VPC Module](terraform/modules/vpc/README.md)
- [ALB Module](terraform/modules/alb/README.md)
- [API Gateway Module](terraform/modules/api_gateway/README.md)
- [Cognito Module](terraform/modules/cognito/README.md)
- [ECS Cluster Module](terraform/modules/ecs/cluster/README.md)
- [ECS Service Module](terraform/modules/ecs/service/README.md)

## Support

For questions or issues:
1. Check the documentation
2. Review existing GitHub issues
3. Create a new issue with details

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Terraform](https://www.terraform.io/)
- Powered by [AWS](https://aws.amazon.com/)
- Inspired by microservices best practices

---

**Ready to deploy your microservices?** Start with the [Terraform guide](terraform/README.md)!