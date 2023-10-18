resource "aws_elasticache_cluster" "redis" {
  cluster_id               = "redis-cluster-${var.family}-${var.environment}"
  engine                   = "redis"
  node_type                = var.node_type
  num_cache_nodes          = 1
  port                     = 6379
  subnet_group_name        = aws_elasticache_subnet_group.default.name
  security_group_ids       = [aws_security_group.redis.id]
  apply_immediately        = true
  snapshot_retention_limit = 0
  tags = {
    Project = var.project_tag
    Environment = var.environment
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "redis-subnet-group-${var.family}-${var.environment}"
  subnet_ids = var.cache_subnet_group_subnet_ids
  lifecycle {
    create_before_destroy = true
  }
}
