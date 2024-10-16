locals {
  master_cloud_init = templatefile("${path.module}/master-cloud-init.yaml", {
    ssh_authorized_key = var.ssh_authorized_key
  })

  worker_cloud_init = templatefile("${path.module}/worker-cloud-init.yaml", {
    ssh_authorized_key = var.ssh_authorized_key
    ssh_private_key    = var.ssh_private_key
  })
}
