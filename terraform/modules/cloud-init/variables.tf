variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key to authorize"
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key to use to connect to the master node"
}
