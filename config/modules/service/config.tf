locals {

  DEFAULT_LOG_CONFIG = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = aws_cloudwatch_log_group.container.name,
      awslogs-region        = var.region,
      awslogs-stream-prefix = "logs"
    }
  }
  DD_LOG_CONFIG = {
    logDriver = "awsfirelens",
    options = {
      Name       = "datadog",
      apiKey     = var.dd_api_key,
      dd_service = var.container_family,
      dd_source  = "fargate-app",
      dd_tags    = "env:${var.environment},environment:${var.environment},service:${var.container_family}",
      TLS        = "on",
      provider   = "ecs"
    }
  }

  DEFAULT_CONTAINER_DEF = {
    name   = "${var.environment}-${var.container_family}"
    image  = var.docker_image
    cpu    = var.cpu
    memory = var.memory
    environment = concat(var.container_env_vars, [
      { name = "REDIS_URL", value = "redis://${var.redis_url}:${var.redis_port}" },
      { name = "DD_SERVICE", value = var.container_family }
    ])
    networkMode      = "awsvpc"
    logConfiguration = var.dd_api_key != null ? local.DD_LOG_CONFIG : local.DEFAULT_LOG_CONFIG
    portMappings = [
      {
        containerPort = var.container_port
        hostPort      = var.container_port
      }
    ]
    repositoryCredentials = {
      credentialsParameter = aws_secretsmanager_secret.github_creds.arn
    }
  }
  DD_CONTAINER_DEF = {
    name  = "datadog-agent-${var.environment}-${var.container_family}",
    image = "public.ecr.aws/datadog/agent:7.40.1",
    environment = [
      {
        name  = "DD_API_KEY",
        value = var.dd_api_key
      },
      {
        name  = "ECS_FARGATE",
        value = "true"
      },
      {
        name  = "DD_APM_ENABLED",
        value = "true"
      },
      {
        name  = "DD_DOGSTATSD_NON_LOCAL_TRAFFIC",
        value = "true"
      },

      {
        name  = "DD_APM_NON_LOCAL_TRAFFIC",
        value = "true"
      },

      {
        name  = "DD_PROCESS_AGENT_ENABLED",
        value = "true"
      },

      {
        name  = "DD_TRACE_ANALYTICS_ENABLED",
        value = "true"
      },

      {
        name  = "DD_RUNTIME_METRICS_ENABLED",
        value = "true"
      },

      {
        name  = "DD_LOGS_INJECTION",
        value = "true"
      }
    ]

    port_mappings = [
      {
        containerPort = 8126
        hostPort      = 8126
        protocol      = "tcp"
      },
      {
        containerPort = 8125
        hostPort      = 8125
        protocol      = "udp"
      },
    ]
  }

  FLUENT_BIT_CONTAINER_DEF = {
    name  = "fluent-bit-agent-${var.environment}-${var.container_family}",
    image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:2.28.4",
    firelensConfiguration = {
      type = "fluentbit",
      options = {
        enable-ecs-log-metadata = "true"
        config-file-type        = "file"
        config-file-value       = "/fluent-bit/configs/parse-json.conf"
      }
    }
  }
  DD_ENABLED_CONTAINER_DEF  = jsonencode([local.DEFAULT_CONTAINER_DEF, local.DD_CONTAINER_DEF, local.FLUENT_BIT_CONTAINER_DEF])
  DD_DISABLED_CONTAINER_DEF = jsonencode([local.DEFAULT_CONTAINER_DEF])
}
