terraform {
  required_providers {
    hcloud = {
      source                = "hetznercloud/hcloud"
      configuration_aliases = [hcloud]
    }
  }
}

resource "hcloud_network" "main" {
  name     = var.network_name
  ip_range = var.network_ip_range
}

resource "hcloud_network_subnet" "subnets" {
  count        = length(var.subnets)
  type         = "cloud"
  network_id   = hcloud_network.main.id
  network_zone = var.subnets[count.index].zone
  ip_range     = var.subnets[count.index].ip_range

  # Optionally, you can use the name in the subnet resource if needed
  # For example, you might want to use it in the "depends_on" block or for naming other resources
  # If not needed, you can remove this line
  depends_on = [hcloud_network.main]
}

