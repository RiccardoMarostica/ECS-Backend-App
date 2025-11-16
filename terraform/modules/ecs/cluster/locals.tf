# ECS Cluster Module Locals

locals {
  cluster_name              = "${var.project_name}-${var.environment}-cluster"
  enable_container_insights = var.enable_container_insights ? "enabled" : "disabled"
}
