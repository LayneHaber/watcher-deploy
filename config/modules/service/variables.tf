variable "execution_role_arn" {}
variable "cluster_id" {}
variable "vpc_id" {}

variable "lb_subnets" {
  type = list(string)
}

variable "docker_image" {}
variable "container_family" {}
variable "project_tag" {}
variable "environment" {}

variable "instance_count" {
  default = 1
}

variable "container_port" {
  default = 8080
}

variable "loadbalancer_port" {
  default = 80
}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_enabled" {
  default = true
}

variable "matcher_ports" {
  default = "200,302"
}

variable "timeout" {
  default = 60
}

variable "region" {}

variable "ingress_cdir_blocks" {
  type = list(string)
}
variable "ingress_ipv6_cdir_blocks" {
  type = list(string)
}

variable "allow_all_cdir_blocks" {
  default = ["0.0.0.0/0"]
}

variable "service_security_groups" {
  type = list(string)
}

variable "base_domain" {
  description = "Base domain of the application"
}

variable "container_env_vars" {
  description = "env vars for running container"
}

variable "github_token" {
  type        = string
  description = "Github token used to read docker image from private github registry. Generate github personal access token with read:packages access."
}

variable "redis_url" {
  type        = string
  description = "Redis url."
}

variable "redis_port" {
  type        = string
  description = "Redis port."
}

variable "dd_api_key" {
  type        = string
  default     = null
  description = "Datadog API key."
}
