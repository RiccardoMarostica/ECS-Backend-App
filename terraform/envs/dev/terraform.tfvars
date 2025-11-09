aws_region   = "eu-west-1"
environment  = "dev"
project_name = "rm-ms-api"

vpc_cidr_block                  = "10.0.0.0/16"
vpc_subnet_public_a_cidr_block  = "10.0.1.0/24"
vpc_subnet_public_b_cidr_block  = "10.0.2.0/24"
vpc_subnet_private_a_cidr_block = "10.0.101.0/24"
vpc_subnet_private_b_cidr_block = "10.0.102.0/24"

# ECS Service Images
users_service_image = "nginx:latest" # Replace with actual ECR image URI