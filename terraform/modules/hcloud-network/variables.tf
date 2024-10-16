variable "network_name" {
  type        = string
  description = "Name of the main network"
}

variable "network_ip_range" {
  type        = string
  description = "IP range of the main network"
}

variable "subnets" {
  type = list(object({
    name     = string
    zone     = string
    ip_range = string
  }))
  description = "List of subnets to create"
}

// Remove the individual subnet variables if they're no longer needed