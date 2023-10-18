variable "az_count" {
  default = 2
}

variable "cidr_block" {}

variable "ecs_cluster_name" {
  description = "Cluster name"
  type        = string
}