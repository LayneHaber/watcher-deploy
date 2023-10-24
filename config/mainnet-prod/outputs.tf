output "watcher-service-endpoint" {
  value = module.watcher.service_endpoint
}

output "watcher-dns" {
  value = module.watcher.dns_name
}

output "cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "redis_address" {
  value = module.redis_cache.redis_instance_address
}

output "redis_port" {
  value = module.redis_cache.redis_instance_port
}