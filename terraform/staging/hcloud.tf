variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key to authorize"
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key to use to connect to the master node"
}

module "network" {
  source = "../modules/hcloud-network"
  providers = {
    hcloud = hcloud
  }

  network_name     = "k3s-cluster"
  network_ip_range = "10.0.0.0/16"

  subnets = [
    {
      name     = "control"
      zone     = "us-east"
      ip_range = "10.0.1.0/24"
    }
  ]
}

module "cloud_init" {
  source = "../modules/cloud-init"

  ssh_authorized_key = var.ssh_authorized_key
  ssh_private_key    = var.ssh_private_key
}

locals {
  ubuntu_image = "ubuntu-24.04"
}

resource "hcloud_server" "master_node" {
  name  = "master-node"
  image = local.ubuntu_image

  server_type = "cpx11"
  location    = "ash" # Ashburn, VA

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = module.network.network_id

    # IP Used by the master node, needs to be static
    # Here the worker nodes will use 10.0.1.1 to communicate with the master node
    ip = "10.0.1.1"
  }

  user_data = module.cloud_init.master_cloud_init_config
}

# resource "hcloud_server" "worker_nodes" {
#   count = 1

#   name        = "worker-node-${count.index}"
#   image       = local.ubuntu_image
#   server_type = "cpx11"
#   location    = "ash"

#   public_net {
#     ipv4_enabled = true
#     ipv6_enabled = false
#   }

#   network {
#     network_id = module.network.network_id
#   }

#   lifecycle {
#     ignore_changes = [network]
#   }

#   user_data = module.cloud_init.worker_cloud_init_config
# }


