variable "sg_id" {
  type        = string
  description = "security group id of worker node sg"
}

variable "vpc_id" {
  type        = string
  description = "underlying vpc id"
}

variable "family" {
  default = "sequencer"
}

variable "cache_subnet_group_subnet_ids" {
  description = "subnet group ids"
  type        = list(string)
}

variable "node_type" {
  description = "node type of redis cluster"
  default     = "cache.t2.small"
  type        = string
}

variable "public_redis" {
  description = "whether to make redis public"
  default     = false
  type        = bool
}

variable "project_tag" {
  description = "Project tag"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}
