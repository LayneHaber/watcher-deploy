resource "aws_ecs_cluster" "infrastructure" {
  name = var.ecs_cluster_name
  tags = {
    Project = var.project_tag
    Environment = var.environment
  }
}

