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

variable "hosted_zone_id" {
  description = "The ID of the hosted zone"
  type        = string
}

## VPC Variables
variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
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

## ECS User service variables
variable "users_service_image" {
  description = "Docker image for the users service (e.g., ECR URI)"
  type        = string
}