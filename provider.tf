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
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.4"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.34.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }
}

provider "equinix" {
  token      = var.auth_token
  auth_token = var.auth_token
}


provider "rancher2" {
  alias = "vcluster" 

  api_url = "https://${local.rancher_host}"
  insecure = true
  token_key = data.external.get_token.result.token
}

provider "rancher2" {
  alias = "harvester"

  api_url = var.rancher_api_url
  insecure = var.rancher_insecure
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
} 

# provider "harvester" {
#   kubeconfig = data.local_file.harvester_kubeconfig[0].content != ""? "${path.module}/../${var.hostname_prefix}$0-rke2.yaml" : "${path.module}/../${var.hostname_prefix}0-rke2.yaml"
# }

# provider "kubernetes" {
#   config_path  = data.local_file.harvester_kubeconfig[0].content != ""? "${path.module}/../${var.hostname_prefix}$0-rke2.yaml" : "${path.module}/../${var.hostname_prefix}0-rke2.yaml"
# }