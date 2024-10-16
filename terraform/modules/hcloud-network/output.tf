output "network_id" {
  value       = hcloud_network.main.id
  description = "ID of the created Hetzner Cloud network"
}

output "subnet_ids" {
  value       = hcloud_network_subnet.subnets[*].id
  description = "IDs of the created subnets"
}

output "subnet_ip_ranges" {
  value       = { for subnet in hcloud_network_subnet.subnets : subnet.ip_range => subnet.id }
  description = "Map of subnet IP ranges to their IDs"
}