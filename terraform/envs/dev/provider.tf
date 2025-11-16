terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "rm-ms-api-dev-terraform"
    key            = "terraform/ms-rm-api/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "rm-ms-api-dev-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}