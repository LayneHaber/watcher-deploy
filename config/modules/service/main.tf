data "aws_route53_zone" "default" {
  name = var.base_domain
}

module "acm_request_certificate" {
  source                            = "cloudposse/acm-request-certificate/aws"
  domain_name                       = var.base_domain
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = ["*.${var.base_domain}"]
  zone_id                           = data.aws_route53_zone.default.zone_id
}

resource "aws_cloudwatch_log_group" "container" {
  name = "${var.container_family}-${var.environment}"
  tags = {
    Family      = var.container_family
    Project     = var.project_tag
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "github_creds" {
  name = "github-creds-${var.environment}"
}

resource "aws_secretsmanager_secret_version" "github_creds" {
  secret_id     = aws_secretsmanager_secret.github_creds.id
  secret_string = "{\"username\":\"USERNAME\",\"password\":\"${var.github_token}\"}"
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.environment}-${var.container_family}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  tags = {
    Family      = var.container_family
    Project     = var.project_tag
    Environment = var.environment
  }
  container_definitions = var.enable_dd_logging ? local.DD_ENABLED_CONTAINER_DEF : local.DD_DISABLED_CONTAINER_DEF
}


resource "aws_ecs_service" "service" {
  name          = "${var.environment}-${var.container_family}"
  cluster       = var.cluster_id
  desired_count = var.instance_count

  launch_type = "FARGATE"
  depends_on  = [aws_alb_target_group.front_end, aws_alb.lb]

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.service.family}:${max("${aws_ecs_task_definition.service.revision}", "${aws_ecs_task_definition.service.revision}")}"

  network_configuration {
    security_groups  = flatten([var.service_security_groups, aws_security_group.lb.id])
    subnets          = var.lb_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.front_end.id
    container_name   = "${var.environment}-${var.container_family}"
    container_port   = var.container_port
  }
}

resource "aws_alb" "lb" {
  security_groups            = var.service_security_groups
  subnets                    = var.lb_subnets
  enable_deletion_protection = false
  idle_timeout               = var.timeout
  tags = {
    Family      = var.container_family
    Project     = var.project_tag
    Environment = var.environment
  }
}


resource "aws_alb_target_group" "front_end" {
  port        = var.loadbalancer_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled  = var.health_check_enabled
    path     = var.health_check_path
    matcher  = var.matcher_ports
    interval = var.timeout + 10
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Family      = var.container_family
    Project     = var.project_tag
    Environment = var.environment
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.acm_request_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.front_end.arn
  }
  tags = {
    Family      = var.container_family
    Project     = var.project_tag
    Environment = var.environment
  }
}

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.loadbalancer_port
    to_port          = var.container_port
    cidr_blocks      = var.ingress_cdir_blocks
    ipv6_cidr_blocks = var.ingress_ipv6_cdir_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allow_all_cdir_blocks
  }
  tags = {
    Family      = var.container_family
    Project     = var.project_tag
    Environment = var.environment

  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "${var.container_family}.${var.environment}.${var.base_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.lb.dns_name]
}


