## Global variables
variable "aws_region" {
  description = "The AWS Region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Defines the deployment environment (development, qa, prod)"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

## VPC Variables
variable "vpc_cidr_block" {
  description = "The CIDR block that will be used for all needed subnets"
  type        = string
}

variable "vpc_instance_tenancy" {
  description = "The tenancy of the VPC"
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated"], var.vpc_instance_tenancy)
    error_message = "The tenancy of the VPC can only be default or dedicated"
  }
}

variable "vpc_enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true  
}

variable "vpc_enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true  
}

variable "vpc_subnet_public_a_cidr_block" {
  description = "The CIDR block that will be used for the public subnet A"
  type        = string  
}

variable "vpc_subnet_public_b_cidr_block" {
  description = "The CIDR block that will be used for the public subnet B"
  type        = string
}

variable "vpc_subnet_private_a_cidr_block" {
  description = "The CIDR block that will be used for the private subnet A"
  type        = string
}

variable "vpc_subnet_private_b_cidr_block" {
  description = "The CIDR block that will be used for the private subnet B"
  type        = string
}