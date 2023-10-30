variable "region" {
  description = "AWS region"
}

variable "cidr_block" {
  default = "172.17.0.0/16"
}

variable "az_count" {
  default = "2"
}

variable "base_domain" {
  description = "Base domain of the application"
}

variable "ecs_cluster_name_prefix" {
  description = "Cluster name prefix"
}

variable "project_tag" {
  description = "Project tag"
  default     = "connext-watcher-v2"
}

variable "full_image_name_watcher" {
  type        = string
  description = "watcher image name"
  default     = "ghcr.io/connext/watcher:sha-b5bb49a"
}

variable "github_token" {
  type        = string
  description = "Github token used to read docker image from private github registry. Generate github personal access token with read:packages access."
}

variable "log_level" {
  type    = string
  default = null
}

variable "environment" {
  type    = string
  default = "mainnet-prod"
}

variable "asset_check_interval" {
  type    = string
  default = null
}

variable "update_variable_interval" {
  type    = string
  default = null
}

variable "gas_multiplier" {
  type    = string
  default = null
}

variable "private_key" {
  type    = string
  default = null
}

variable "web3_signer_url" {
  type    = string
  default = null
}

variable "discord_hook_url" {
  type    = string
  default = null
}

variable "pager_duty_routing_key" {
  type    = string
  default = null
}

variable "server_port" {
  type    = number
  default = 8080
}

variable "server_host" {
  type    = string
  default = null
}

variable "server_admin_token" {
  type    = string
  default = null
}

variable "twilio_number" {
  type    = string
  default = null
}

variable "twilio_to_phone_numbers" {
  type    = string
  default = null
}

variable "twilio_account_sid" {
  type    = string
  default = null
}

variable "twilio_auth_token" {
  type    = string
  default = null
}

variable "telegram_chat_id" {
  type    = string
  default = null
}

variable "telegram_api_key" {
  type    = string
  default = null
}

variable "better_uptime_email" {
  type    = string
  default = null
}

variable "better_uptime_api_key" {
  type    = string
  default = null
}

variable "custom_rpc_providers" {
  type    = string
  default = null
}

variable "public_redis" {
  type    = bool
  default = true
}

variable "redis_node_type" {
  type    = string
  default = "cache.r4.large"
}

# 
# DEVNET ENVIRONMENT VARIABLES
# 
variable "tenderly_access_key" {
  type    = string
  default = null
}

variable "tenderly_account_id" {
  type    = string
  default = null
}

variable "tenderly_project_slug" {
  type    = string
  default = null
}

variable "dd_api_key" {
  type        = string
  default     = null
  description = "Datadog API key."
}
