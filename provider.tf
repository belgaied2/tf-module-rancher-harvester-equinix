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
  }
}

provider "equinix" {
  token      = var.auth_token
  auth_token = var.auth_token
}

provider "rancher2" {
  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
  insecure   = var.rancher_insecure
}