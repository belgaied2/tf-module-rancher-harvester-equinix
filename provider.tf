terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "1.34.1"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "4.1.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.34.0"
    }
  }
}
