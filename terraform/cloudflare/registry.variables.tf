variable "registry_username" {
  type        = string
  sensitive   = true
  description = "Username for basic auth on the container registry"
}

variable "registry_password" {
  type        = string
  sensitive   = true
  description = "Password for basic auth on the container registry"
}
