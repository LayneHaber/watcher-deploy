terraform {
  backend "s3" {
    bucket = "connext-terraform-watcher-v2-testnet-staging"
    key    = "state"
    region = "eu-central-1"
  }
  required_version = "~> 1.4.4"
}

provider "aws" {
  region = var.region
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}


data "aws_caller_identity" "current" {}


module "watcher" {
  source                   = "../modules/service"
  region                   = var.region
  execution_role_arn       = module.iam.execution_role_arn
  cluster_id               = module.ecs.ecs_cluster_id
  vpc_id                   = module.network.vpc_id
  lb_subnets               = module.network.public_subnets
  docker_image             = var.full_image_name_watcher
  container_family         = "watcher-v2"
  project_tag              = var.project_tag
  environment              = var.environment
  health_check_path        = "/ping"
  container_port           = var.server_port
  loadbalancer_port        = 80
  cpu                      = 1024
  memory                   = 2048
  instance_count           = 1
  timeout                  = 180
  ingress_cdir_blocks      = [module.network.vpc_cdir_block]
  ingress_ipv6_cdir_blocks = []
  service_security_groups  = flatten([module.network.allow_all_sg, module.network.ecs_task_sg])
  container_env_vars       = local.watcher_env_vars
  base_domain              = var.base_domain
  github_token             = var.github_token
  redis_url                = module.redis_cache.redis_instance_address
  redis_port               = module.redis_cache.redis_instance_port
  dd_api_key               = var.dd_api_key
}

module "redis_cache" {
  source                        = "../modules/redis"
  family                        = var.project_tag
  sg_id                         = module.network.ecs_task_sg
  vpc_id                        = module.network.vpc_id
  cache_subnet_group_subnet_ids = module.network.public_subnets
  node_type                     = var.redis_node_type
  public_redis                  = var.public_redis
  project_tag                   = var.project_tag
  environment                   = var.environment
}

module "network" {
  source           = "../modules/networking"
  cidr_block       = var.cidr_block
  ecs_cluster_name = module.ecs.ecs_cluster_name
}


module "ecs" {
  source                  = "../modules/ecs"
  ecs_cluster_name_prefix = var.ecs_cluster_name_prefix
  project_tag             = var.project_tag
  environment             = var.environment
}


module "iam" {
  source           = "../modules/iam"
  ecs_cluster_name = module.ecs.ecs_cluster_name
}
