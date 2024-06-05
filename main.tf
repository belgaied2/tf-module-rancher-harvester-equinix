locals {

  rancher_host = format("rancher.%s.nip.io", module.harvester_cluster[0].public_ips[0])
  equinix_management_private_ipv4 = jsondecode(data.http.get_management_private_ipv4[0].response_body).ip_addresses[0]
  private_ip_range_to_attach = cidrsubnet(join("/", [local.equinix_management_private_ipv4.network, local.equinix_management_private_ipv4.cidr]), 1, 1) 
}


module "harvester_cluster" {

  providers = {
    rancher2 = rancher2.harvester
  }

  count             = var.cluster_count
  source            = "../terraform-harvester-equinix"
  harvester_version = "v1.2.1"
  node_count        = var.node_count
  project_name      = var.project_name
  metro             = var.metro
  ssh_key           = var.ssh_key
  hostname_prefix   = "${var.hostname_prefix}${count.index}"
  spot_instance     = true
  max_bid_price     = 0.15
  plan              = "m3.small.x86"
  api_key           = var.auth_token
  use_cheapest_metro= false
  num_of_public_ips = 4
  #num_of_vlans = 4
}

data "equinix_metal_project" "project_id" {
  name = var.project_name
}

data "http" "get_management_private_ipv4" {
  count = var.cluster_count

  url = "https://api.equinix.com/metal/v1/projects/${data.equinix_metal_project.project_id.id}/ips?types=private_ipv4&include=metro&metro=${var.metro}&exclude=assignment"
  request_headers =  {
    "X-Auth-Token" = var.auth_token
    
  }

  depends_on = [ module.harvester_cluster ]
}

output "private_ipv4_ranges" {
  value =  cidrsubnet(join("/", [local.equinix_management_private_ipv4.network, local.equinix_management_private_ipv4.cidr]), 1, 1)
}


resource "equinix_metal_ip_attachment" "attach_private_ips_to_nodes" {
  count = var.cluster_count 

  device_id = module.harvester_cluster[count.index ].nodes[0]
  cidr_notation = local.private_ip_range_to_attach
  
}

resource "null_resource" "kubeconfig" {

  count = var.cluster_count

  provisioner "local-exec" {
    command = "NAME=${var.hostname_prefix}${count.index} IP=${module.harvester_cluster[count.index].public_ips[0]} SSH_PRIVATE_KEY_FILE=${var.ssh_private_key_file} scripts/get_kubeconfig.sh"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm -f ../*.yaml ../*.txt"
  }
}

resource "null_resource" "set_password" {

  count = var.cluster_count

  provisioner "local-exec" {
    command = "HOST=${replace(replace(module.harvester_cluster[count.index].harvester_url,"https://", ""),"/","")} BOOTSTRAP_PASSWORD=${var.bootstrap_password} NEW_PASSWORD=${var.harvester_password} scripts/set_password.sh"
  }

  depends_on = [null_resource.kubeconfig]
}


module "create_vcluster_namespace" {
  source          = "./modules/apply_manifest"
  count           = var.cluster_count
  kubeconfig_file = "${path.module}/../${var.hostname_prefix}${count.index}-rke2.yaml"
  manifest        = templatefile("${path.module}/templates/rancher-vcluster-namespace.yaml.tmpl", {})
  
  depends_on      = [null_resource.set_password]
}

module "create_vcluster" {
  source          = "./modules/apply_manifest"
  count           = var.cluster_count
  kubeconfig_file = "${path.module}/../${var.hostname_prefix}${count.index}-rke2.yaml"
  manifest = templatefile("${path.module}/templates/rancher-vcluster.yaml.tmpl", {
    rancher_hostname           = local.rancher_host,
    rancher_bootstrap_password = var.rancher_bootstrap_password
  })
  depends_on = [module.create_vcluster_namespace]
}

resource "null_resource" "set_password_rancher" {

  count = var.cluster_count

  provisioner "local-exec" {
    command = "HOST=${local.rancher_host} BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} NEW_PASSWORD=${var.rancher_password} scripts/set_password_rancher.sh"
  }

  depends_on = [module.create_vcluster]
}

data "external" "get_token" {
  program = ["/bin/bash", "-c","HOST=${local.rancher_host} USERNAME=admin PASSWORD=${var.rancher_password} scripts/get_token_rancher.sh"]

  depends_on = [null_resource.set_password_rancher]
}

resource "null_resource" "update_server_url" {
  
  count = var.cluster_count
  
  provisioner "local-exec" {
    command = "RANCHER_URL=https://${local.rancher_host} TOKEN=${data.external.get_token.result.token} scripts/update_server_url.sh"

  }
}

module "import_harvester" {
  source          = "./modules/rancher_import_harvester"
  
  count = var.cluster_count

  rancher_token = data.external.get_token.result.token
  rancher_url      = "https://${local.rancher_host}" 
  harvester_config_path = "${path.module}/../${var.hostname_prefix}${count.index}-rke2.yaml"
  depends_on = [ null_resource.update_server_url ]
}

