output "master_cloud_init_config" {
  value       = local.master_cloud_init
  description = "Rendered cloud-init configuration for master node"
}

output "worker_cloud_init_config" {
  value       = local.worker_cloud_init
  description = "Rendered cloud-init configuration for worker node"
}
