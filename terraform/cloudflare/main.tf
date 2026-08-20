terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.23"
    }
  }

  backend "s3" {
    bucket                      = "terraform-state-hetzner-k3s-cluster"
    key                         = "cloudflare/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

provider "cloudflare" {
  # Authenticates via the CLOUDFLARE_API_TOKEN environment variable
  # (exported from .envrc-secrets, see .envrc-secrets.template).
}
