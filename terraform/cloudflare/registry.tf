# R2-backed container registry, based on https://github.com/cloudflare/serverless-registry.
#
# The worker source lives in a sibling clone of that repo (see README.md).
# Build the bundle with ./build-r2-registry.sh before running plan/apply.

locals {
  registry_worker_bundle = "${path.module}/../../../serverless-registry/dist/index.js"
}

resource "cloudflare_r2_bucket" "registry" {
  account_id = var.cloudflare_account_id
  name       = "r2-registry"
}

resource "cloudflare_workers_script" "registry" {
  account_id  = var.cloudflare_account_id
  script_name = "r2-registry-production"

  content_file   = local.registry_worker_bundle
  content_sha256 = filesha256(local.registry_worker_bundle)
  main_module    = "index.js"

  compatibility_date  = "2022-04-18"
  compatibility_flags = ["streams_enable_constructors"]

  bindings = [
    {
      name        = "REGISTRY"
      type        = "r2_bucket"
      bucket_name = cloudflare_r2_bucket.registry.name
    },
    {
      name = "USERNAME"
      type = "secret_text"
      text = var.registry_username
    },
    {
      name = "PASSWORD"
      type = "secret_text"
      text = var.registry_password
    },
  ]
}

# Serves the worker at r2-registry-production.mbenedettini-cloudflare.workers.dev
resource "cloudflare_workers_script_subdomain" "registry" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_workers_script.registry.script_name
  enabled     = true
}
