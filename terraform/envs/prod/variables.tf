## Global variables
variable "aws_region" {
    description = "The AWS Region where resources will be created"
    type = string
}

variable "environment" {
  description = "Defines the deployment environment (development, qa, prod)"
  type = string
}

variable "project_name" {
  description = "The name of the project"
  type = string
}