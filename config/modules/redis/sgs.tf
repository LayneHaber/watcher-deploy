resource "aws_security_group" "redis" {
  name   = "redis-cluster-${var.family}-${var.environment}-sg"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  lifecycle {
    ignore_changes = [
      ingress,
    ]
  }
  tags = {
    Project = var.project_tag
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "redis_ingress_cidr_blocks" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["172.17.0.0/16"]
  security_group_id = aws_security_group.redis.id
}


resource "aws_security_group_rule" "allow_res_to_redis" {
  description              = "Allow worker nodes to communicate with cache"
  from_port                = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = var.sg_id
  to_port                  = 6379
  type                     = "ingress"
}



resource "aws_security_group" "allow_from_anywhere" {
  count       = var.public_redis ? 1 : 0
  description = "Allow all inbound traffic"
  name        = "redis-cluster-${var.family}-${var.environment}-allow-all"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group_rule" "allow_all_to_redis" {
  count                    = var.public_redis ? 1 : 0
  description              = "Allow worker nodes to communicate with cache"
  from_port                = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.allow_from_anywhere[0].id
  to_port                  = 6379
  type                     = "ingress"
}

