# API Gateway Module

This Terraform module creates an AWS API Gateway REST API with Cognito authentication, VPC Link integration to an internal ALB, and proxy configuration for routing all requests to backend services.

## Features

- REST API with configurable endpoint type (REGIONAL or EDGE)
- Cognito User Pool authorization
- VPC Link integration to internal Application Load Balancer
- Proxy resource for catch-all routing ({proxy+})
- Automatic redeployment on configuration changes
- Configurable token TTL for authorization caching
- Support for IPv4 and IPv6

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

- `aws_api_gateway_rest_api` - REST API
- `aws_api_gateway_authorizer` - Cognito User Pool authorizer
- `aws_api_gateway_resource` - Proxy resource ({proxy+})
- `aws_api_gateway_method` - ANY method with Cognito authorization
- `aws_api_gateway_integration` - HTTP_PROXY integration to ALB via VPC Link
- `aws_api_gateway_deployment` - API deployment
- `aws_api_gateway_stage` - API stage

## Usage

### Basic Example

```hcl
module "api_gateway" {
  source = "./modules/api_gateway"

  rest_api_name                         = "myapp-api"
  rest_api_stage_name                   = "dev"
  rest_api_authorizer_name              = "cognito-authorizer"
  rest_api_authorizer_cognito_provider  = [module.cognito.cognito_user_pool_arn]
  alb_vpc_link_id                       = module.alb.alb_vpc_link_id
  alb_listener_arn                      = module.alb.listener_arn
}
```

### Production Example with Custom Settings

```hcl
module "api_gateway" {
  source = "./modules/api_gateway"

  rest_api_name                         = "myapp-prod-api"
  rest_api_stage_name                   = "prod"
  rest_api_endpoint_type                = "REGIONAL"
  rest_api_endpoint_ip_address_type     = "ipv4"
  rest_api_disable_execute_endpoint     = true
  
  rest_api_authorizer_name              = "cognito-authorizer"
  rest_api_authorizer_type              = "COGNITO_USER_POOLS"
  rest_api_authorizer_ttl               = 300
  rest_api_authorizer_cognito_provider  = [module.cognito.cognito_user_pool_arn]
  
  alb_vpc_link_id                       = module.alb.alb_vpc_link_id
  alb_listener_arn                      = module.alb.listener_arn
}
```

### Complete Integration Example

```hcl
# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  aws_region   = "us-east-1"
  environment  = "dev"
  project_name = "myapp"
  
  vpc_cidr_block                   = "10.0.0.0/16"
  vpc_subnet_public_a_cidr_block   = "10.0.1.0/24"
  vpc_subnet_public_b_cidr_block   = "10.0.2.0/24"
  vpc_subnet_private_a_cidr_block  = "10.0.11.0/24"
  vpc_subnet_private_b_cidr_block  = "10.0.12.0/24"
}

# ALB Module
module "alb" {
  source = "./modules/alb"
  
  aws_region          = "us-east-1"
  environment         = "dev"
  project_name        = "myapp"
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = "10.0.0.0/16"
  vpc_private_subnets = module.vpc.private_subnets
}

# Cognito Module
module "cognito" {
  source = "./modules/cognito"
  
  user_pool_name               = "myapp-users"
  user_pool_client_name        = "myapp-client"
  user_pool_domain_name        = "myapp-dev"
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api_gateway"
  
  rest_api_name                         = "myapp-api"
  rest_api_stage_name                   = "dev"
  rest_api_authorizer_name              = "cognito-authorizer"
  rest_api_authorizer_cognito_provider  = [module.cognito.cognito_user_pool_arn]
  alb_vpc_link_id                       = module.alb.alb_vpc_link_id
  alb_listener_arn                      = module.alb.listener_arn
}

# Outputs
output "api_url" {
  value = module.api_gateway.api_gateway_invoke_url
}
```

### Edge-Optimized API Example

```hcl
module "api_gateway" {
  source = "./modules/api_gateway"

  rest_api_name                         = "myapp-global-api"
  rest_api_stage_name                   = "prod"
  rest_api_endpoint_type                = "EDGE"  # CloudFront distribution
  rest_api_authorizer_name              = "cognito-authorizer"
  rest_api_authorizer_cognito_provider  = [module.cognito.cognito_user_pool_arn]
  alb_vpc_link_id                       = module.alb.alb_vpc_link_id
  alb_listener_arn                      = module.alb.listener_arn
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| rest_api_name | The name of the REST API | `string` |
| rest_api_stage_name | The name of the stage, which is exactly the name of the environment | `string` |
| rest_api_authorizer_name | The name of the authorizer | `string` |
| rest_api_authorizer_cognito_provider | List of the Amazon Cognito user pool ARNs | `list(string)` |
| alb_vpc_link_id | The ID of the VPC Link | `string` |
| alb_listener_arn | The ARN of the ALB Listener | `string` |

### Optional Variables

| Name | Description | Type | Default | Valid Values |
|------|-------------|------|---------|--------------|
| rest_api_disable_execute_endpoint | Whether clients can invoke the REST API using the default execute-api endpoint | `bool` | `false` | `true`, `false` |
| rest_api_endpoint_ip_address_type | The IP address type that can invoke an API | `string` | `"ipv4"` | `"ipv4"`, `"ipv6"` |
| rest_api_endpoint_type | The type of endpoint for the REST API | `string` | `"REGIONAL"` | `"EDGE"`, `"REGIONAL"` |
| rest_api_authorizer_type | The type of the authorizer | `string` | `"COGNITO_USER_POOLS"` | - |
| rest_api_authorizer_ttl | The TTL of cached authorizer results (in seconds) | `number` | `300` | 0-3600 |

## Outputs

| Name | Description |
|------|-------------|
| api_gateway_invoke_url | The base URL to invoke the API Gateway stage |
| api_gateway_id | The ID of the API Gateway REST API |
| api_gateway_execution_arn | The execution ARN of the API Gateway REST API |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet/Clients                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ HTTPS (with Cognito token)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   API Gateway REST API                       │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Cognito Authorizer                                   │  │
│  │  - Validates JWT tokens                               │  │
│  │  - Caches results (TTL: 300s)                        │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Resource: /{proxy+}                                  │  │
│  │  Method: ANY                                          │  │
│  │  Authorization: COGNITO_USER_POOLS                    │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Integration: HTTP_PROXY                              │  │
│  │  Connection: VPC_LINK                                 │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ VPC Link
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                         VPC                                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Internal ALB                              │  │
│  └──────────────────────┬────────────────────────────────┘  │
│                         │                                    │
│                         ▼                                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              ECS Services                              │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Request Flow

1. Client sends request to API Gateway with Cognito JWT token in Authorization header
2. API Gateway validates token using Cognito Authorizer
3. If valid, request is forwarded through VPC Link to internal ALB
4. ALB routes request to appropriate ECS service
5. Response flows back through the same path

## Authentication

This module uses Cognito User Pools for authentication:

- Authorization header must contain a valid JWT token
- Token format: `Authorization: Bearer <jwt_token>`
- Tokens are cached for the TTL period (default 300 seconds)
- Identity source: `method.request.header.Authorization`

### Getting a Token

```bash
# Using AWS CLI
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id <client-id> \
  --auth-parameters USERNAME=<username>,PASSWORD=<password>

# Using the token
curl -H "Authorization: Bearer <id_token>" \
  https://<api-id>.execute-api.<region>.amazonaws.com/<stage>/path
```

## Troubleshooting

### Common Issues

#### 1. Unauthorized Error (401)

**Error:**
```json
{"message":"Unauthorized"}
```

**Causes & Solutions:**

1. **Missing or invalid token:**
```bash
# Ensure Authorization header is present
curl -H "Authorization: Bearer <valid-token>" <api-url>
```

2. **Token expired:**
```bash
# Get a new token from Cognito
aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH ...
```

3. **Wrong Cognito User Pool:**
```hcl
# Verify the correct User Pool ARN
rest_api_authorizer_cognito_provider = [module.cognito.cognito_user_pool_arn]
```

#### 2. VPC Link Connection Timeout

**Error:**
```json
{"message":"Internal server error"}
```

**Solution:**

1. Check VPC Link status:
```bash
aws apigateway get-vpc-link --vpc-link-id <vpc-link-id>
```

2. Verify ALB is healthy:
```bash
aws elbv2 describe-load-balancers --load-balancer-arns <alb-arn>
```

3. Check ALB target health:
```bash
aws elbv2 describe-target-health --target-group-arn <tg-arn>
```

#### 3. Integration URI Error

**Error:**
```
Error: error creating API Gateway Integration: BadRequestException: Invalid URI
```

**Solution:**

The `alb_listener_arn` should be the ALB ARN, not the listener ARN. This is a naming issue in the module:

```hcl
# Correct usage (despite variable name)
alb_listener_arn = module.alb.alb_arn  # Not listener_arn!
```

Or update the integration in main.tf:
```hcl
resource "aws_api_gateway_integration" "proxy" {
  # ...
  uri = "http://${alb_dns_name}"  # Use DNS name instead
}
```

#### 4. API Gateway Not Redeploying

**Symptoms:**
- Changes to API Gateway not taking effect
- Old configuration still active

**Solution:**

The module uses SHA1 hash for redeployment triggers. If changes aren't detected:

```bash
# Force redeployment
terraform taint module.api_gateway.aws_api_gateway_deployment.main
terraform apply
```

#### 5. CORS Issues

**Error:**
```
Access to fetch at 'https://api.example.com' from origin 'https://app.example.com' 
has been blocked by CORS policy
```

**Solution:**

This module doesn't configure CORS. You need to add OPTIONS method and CORS headers:

```hcl
# Add to your configuration
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
```

#### 6. Stage Not Found After Deployment

**Error:**
```
Error: error reading API Gateway Stage: NotFoundException
```

**Solution:**

Ensure deployment completes before stage creation:

```hcl
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  # ...
  
  depends_on = [aws_api_gateway_deployment.main]
}
```

## Limitations

1. **Single Proxy Resource**: Only supports catch-all {proxy+} routing
2. **No CORS Support**: CORS headers not configured
3. **HTTP Only**: Integration uses HTTP, not HTTPS to ALB
4. **No Custom Domain**: Custom domain names not supported
5. **No WAF**: Web Application Firewall not integrated
6. **No API Keys**: API key authentication not configured
7. **No Usage Plans**: Rate limiting and throttling not configured
8. **No Logging**: CloudWatch logging not enabled
9. **Variable Naming Issue**: `alb_listener_arn` should accept ALB ARN, not listener ARN

## Best Practices

1. **Enable Execute API Endpoint Protection**: Set `rest_api_disable_execute_endpoint = true` in production when using custom domains
2. **Use Regional Endpoints**: Prefer REGIONAL over EDGE for lower latency within a region
3. **Configure Appropriate TTL**: Balance between performance (higher TTL) and security (lower TTL)
4. **Enable CloudWatch Logs**: Add logging for debugging and monitoring
5. **Use Custom Domains**: Configure custom domain names for production APIs
6. **Implement Rate Limiting**: Add usage plans and API keys for rate limiting
7. **Enable WAF**: Protect against common web exploits

## Security Considerations

- All requests require valid Cognito JWT tokens
- Authorization results are cached (default 300 seconds)
- API Gateway validates tokens before forwarding to backend
- VPC Link keeps backend services private (not internet-accessible)
- Consider enabling AWS WAF for additional protection
- Enable CloudWatch logging for security monitoring

## Cost Considerations

This module creates resources with the following costs:

- API Gateway REST API: $3.50 per million requests
- VPC Link: $0.01 per hour (~$7.20/month)
- Data Transfer: $0.09 per GB (out to internet)
- CloudWatch Logs: $0.50 per GB ingested (if enabled)

Estimated monthly cost: ~$7.20 + usage-based charges

## Future Enhancements

- Add CORS configuration support
- Add custom domain name support
- Add CloudWatch logging configuration
- Add WAF integration
- Add usage plans and API keys
- Support for multiple resources and methods
- Add request/response validation
- Add caching configuration
- Support for HTTPS integration to ALB
- Fix variable naming (alb_listener_arn should be alb_arn)

## Notes

- **Proxy Resource**: The {proxy+} resource catches all paths and forwards to ALB
- **ANY Method**: Supports all HTTP methods (GET, POST, PUT, DELETE, etc.)
- **Automatic Redeployment**: API redeploys automatically when resources change
- **Variable Naming**: Despite the name `alb_listener_arn`, this should be the ALB ARN for the integration URI

## License

See the LICENSE file in the root of the repository.
