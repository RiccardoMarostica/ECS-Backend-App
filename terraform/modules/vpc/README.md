# VPC Module

This Terraform module creates a complete VPC infrastructure with public and private subnets across two availability zones, including internet gateway and route tables for a highly available network architecture.

## Features

- VPC with configurable CIDR block
- 2 public subnets across different availability zones
- 2 private subnets across different availability zones
- Internet Gateway for public subnet connectivity
- Separate route tables for public and private subnets
- DNS support and DNS hostnames enabled by default
- Configurable instance tenancy

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

- `aws_vpc` - Virtual Private Cloud
- `aws_subnet` (x4) - 2 public and 2 private subnets
- `aws_internet_gateway` - Internet Gateway for public internet access
- `aws_route_table` (x2) - Public and private route tables
- `aws_route_table_association` (x4) - Route table associations for all subnets

## Usage

### Basic Example

```hcl
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
```

### Production Example with Custom Settings

```hcl
module "vpc" {
  source = "./modules/vpc"

  aws_region   = "us-east-1"
  environment  = "prod"
  project_name = "myapp"

  vpc_cidr_block           = "10.0.0.0/16"
  vpc_instance_tenancy     = "default"
  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true

  vpc_subnet_public_a_cidr_block   = "10.0.1.0/24"
  vpc_subnet_public_b_cidr_block   = "10.0.2.0/24"
  vpc_subnet_private_a_cidr_block  = "10.0.11.0/24"
  vpc_subnet_private_b_cidr_block  = "10.0.12.0/24"
}
```

### Integration with ALB Module

```hcl
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

module "alb" {
  source = "./modules/alb"

  aws_region          = "us-east-1"
  environment         = "dev"
  project_name        = "myapp"
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = "10.0.0.0/16"
  vpc_private_subnets = module.vpc.private_subnets
}
```

### Integration with ECS Module

```hcl
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

module "ecs_cluster" {
  source = "./modules/ecs/cluster"

  # ... other variables ...
  vpc_id         = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| aws_region | The AWS Region where resources will be created | `string` |
| environment | Defines the deployment environment (development, qa, prod) | `string` |
| project_name | The name of the project | `string` |
| vpc_cidr_block | The CIDR block that will be used for all needed subnets | `string` |
| vpc_subnet_public_a_cidr_block | The CIDR block that will be used for the public subnet A | `string` |
| vpc_subnet_public_b_cidr_block | The CIDR block that will be used for the public subnet B | `string` |
| vpc_subnet_private_a_cidr_block | The CIDR block that will be used for the private subnet A | `string` |
| vpc_subnet_private_b_cidr_block | The CIDR block that will be used for the private subnet B | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| vpc_instance_tenancy | The tenancy of the VPC (default or dedicated) | `string` | `"default"` |
| vpc_enable_dns_support | A boolean flag to enable/disable DNS support in the VPC | `bool` | `true` |
| vpc_enable_dns_hostnames | A boolean flag to enable/disable DNS hostnames in the VPC | `bool` | `true` |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| private_subnets | List of IDs of private subnets |
| public_subnets | List of IDs of public subnets |
| public_route_table_id | The ID of the public route table |
| public_route_table_arn | The ARN of the public route table |
| private_route_table_id | The ID of the private route table |
| private_route_table_arn | The ARN of the private route table |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Internet Gateway                       │    │
│  └──────────────────┬─────────────────────────────────┘    │
│                     │                                        │
│  ┌──────────────────┴─────────────────────────────────┐    │
│  │           Public Route Table                        │    │
│  │           Route: 0.0.0.0/0 -> IGW                  │    │
│  └──────────────────┬─────────────────────────────────┘    │
│                     │                                        │
│  ┌──────────────────┴──────────────┬────────────────────┐  │
│  │                                  │                     │  │
│  │  Public Subnet A (us-east-1a)   │  Public Subnet B   │  │
│  │  10.0.1.0/24                     │  10.0.2.0/24       │  │
│  │  (Auto-assign public IP)         │  (us-east-1a)      │  │
│  └──────────────────────────────────┴────────────────────┘  │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Private Route Table                        │   │
│  │           (No internet route)                        │   │
│  └──────────────────┬──────────────────────────────────┘   │
│                     │                                        │
│  ┌──────────────────┴──────────────┬────────────────────┐  │
│  │                                  │                     │  │
│  │  Private Subnet A (us-east-1a)  │  Private Subnet B  │  │
│  │  10.0.11.0/24                    │  10.0.12.0/24      │  │
│  │                                  │  (us-east-1b)      │  │
│  └──────────────────────────────────┴────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## CIDR Block Planning

When planning your CIDR blocks, consider:

- VPC CIDR should be large enough to accommodate all subnets
- Leave room for future subnet expansion
- Avoid overlapping with other VPCs if VPC peering is planned

### Example CIDR Schemes

**Small Environment (256 IPs per subnet):**
```hcl
vpc_cidr_block                   = "10.0.0.0/16"
vpc_subnet_public_a_cidr_block   = "10.0.1.0/24"   # 256 IPs
vpc_subnet_public_b_cidr_block   = "10.0.2.0/24"   # 256 IPs
vpc_subnet_private_a_cidr_block  = "10.0.11.0/24"  # 256 IPs
vpc_subnet_private_b_cidr_block  = "10.0.12.0/24"  # 256 IPs
```

**Large Environment (1024 IPs per subnet):**
```hcl
vpc_cidr_block                   = "10.0.0.0/16"
vpc_subnet_public_a_cidr_block   = "10.0.0.0/22"   # 1024 IPs
vpc_subnet_public_b_cidr_block   = "10.0.4.0/22"   # 1024 IPs
vpc_subnet_private_a_cidr_block  = "10.0.8.0/22"   # 1024 IPs
vpc_subnet_private_b_cidr_block  = "10.0.12.0/22"  # 1024 IPs
```

## Troubleshooting

### Common Issues

#### 1. CIDR Block Overlap

**Error:**
```
Error: error creating subnet: InvalidSubnet.Conflict: The CIDR '10.0.1.0/24' conflicts with another subnet
```

**Solution:**
Ensure all subnet CIDR blocks are within the VPC CIDR and don't overlap:

```hcl
# VPC: 10.0.0.0/16 can contain 10.0.0.0 - 10.0.255.255
vpc_cidr_block                   = "10.0.0.0/16"
vpc_subnet_public_a_cidr_block   = "10.0.1.0/24"   # ✓ Valid
vpc_subnet_public_b_cidr_block   = "10.0.2.0/24"   # ✓ Valid
vpc_subnet_private_a_cidr_block  = "10.0.1.0/24"   # ✗ Overlaps with public_a
```

#### 2. Availability Zone Not Available

**Error:**
```
Error: error creating subnet: InvalidInput: The availability zone 'us-east-1c' is not available
```

**Solution:**
The module hardcodes availability zones. If your region doesn't have the specified AZs, you'll need to modify `main.tf`:

```hcl
# Check available AZs in your region
aws ec2 describe-availability-zones --region us-east-1
```

#### 3. Both Public Subnets in Same AZ

**Issue:**
Both public subnets are created in `us-east-1a` (line 18 and 25 in main.tf)

**Solution:**
This appears to be a bug. Public subnet B should be in a different AZ:

```hcl
# Current (incorrect):
resource "aws_subnet" "public_b" {
  availability_zone = "${var.aws_region}a"  # Should be 'b'
}

# Should be:
resource "aws_subnet" "public_b" {
  availability_zone = "${var.aws_region}b"
}
```

#### 4. DNS Resolution Not Working

**Symptoms:**
- Cannot resolve DNS names within VPC
- Services cannot communicate using DNS

**Solution:**
Ensure DNS support and hostnames are enabled:

```hcl
vpc_enable_dns_support   = true
vpc_enable_dns_hostnames = true
```

#### 5. Private Subnets Cannot Access Internet

**Expected Behavior:**
Private subnets in this module do NOT have internet access by design (no NAT Gateway).

**Solution:**
If you need internet access from private subnets:

1. Add NAT Gateway to the module
2. Update private route table to route through NAT Gateway
3. Consider costs (NAT Gateway is ~$32/month + data transfer)

```hcl
# Example NAT Gateway addition (not included in module)
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
}

# Add to private route table
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
```

#### 6. VPC Deletion Fails

**Error:**
```
Error: error deleting VPC: DependencyViolation: The vpc has dependencies and cannot be deleted
```

**Solution:**
Ensure all resources using the VPC are deleted first:

```bash
# Check for remaining ENIs
aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=<vpc-id>"

# Check for remaining security groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<vpc-id>"
```

## Limitations

1. **Fixed Availability Zones**: Subnets are created in hardcoded AZs (a and b)
2. **No NAT Gateway**: Private subnets cannot access the internet
3. **No VPC Flow Logs**: Network traffic logging not enabled
4. **No VPC Endpoints**: No S3 or other service endpoints configured
5. **Single Route Table per Type**: All public subnets share one route table, all private subnets share another
6. **Bug**: Both public subnets are in the same AZ (us-east-1a)

## Best Practices

1. **Use /16 for VPC CIDR**: Provides 65,536 IPs for future growth
2. **Use /24 for Subnets**: Provides 256 IPs per subnet (251 usable)
3. **Enable DNS**: Always keep DNS support and hostnames enabled
4. **Multi-AZ**: Ensure subnets span multiple AZs for high availability
5. **Reserve CIDR Space**: Don't use all available CIDR space immediately
6. **Tag Resources**: Use consistent tagging for cost allocation and management

## Security Considerations

- Public subnets have `map_public_ip_on_launch = true` - instances get public IPs automatically
- Private subnets have no internet access (no NAT Gateway)
- No Network ACLs configured (uses default allow-all)
- No VPC Flow Logs for traffic monitoring
- Internet Gateway allows all outbound traffic from public subnets

## Cost Considerations

This module creates resources with the following costs:

- VPC: Free
- Subnets: Free
- Internet Gateway: Free
- Route Tables: Free
- Data Transfer: Charged per GB

Total: ~$0/month (excluding data transfer)

## Future Enhancements

- Add NAT Gateway support for private subnet internet access
- Make availability zones configurable
- Add VPC Flow Logs support
- Add VPC Endpoints for S3, ECR, etc.
- Add Network ACL configuration
- Support for IPv6
- Add VPC peering support
- Fix public subnet B availability zone bug

## Notes

- **Availability Zone Bug**: Public subnet B is created in the same AZ as public subnet A (both in `us-east-1a`). This should be fixed to use `us-east-1b` for proper multi-AZ deployment.
- **Naming Convention**: All resources follow the pattern `{project_name}-{environment}-{resource_type}`
- **No NAT Gateway**: This is a cost-saving measure but limits private subnet functionality

## License

See the LICENSE file in the root of the repository.
