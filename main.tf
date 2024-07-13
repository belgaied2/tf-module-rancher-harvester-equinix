locals {
  rancher_host = cloudflare_record.dns_record_rancher.hostname
  rancher_token = jsondecode(data.http.get_token.response_body).token
}


module "harvester_cluster" {

  source            = "./modules/terraform-harvester-equinix"
  harvester_version = var.harvester_version
  node_count        = var.node_count
  project_name      = var.project_name
  metro             = var.metro
  ssh_key           = var.ssh_key
  hostname_prefix   = "${var.hostname_prefix}${var.cluster_number}"
  spot_instance     = true
  max_bid_price     = 0.15
  plan              = "m3.small.x86"
  api_key           = var.auth_token
  use_cheapest_metro= false
  num_of_vlans = var.num_of_vlans
  cluster_number = var.cluster_number
#   additional_os_config = <<-EOT
#   write_files:
# %{ for i in range(var.num_of_vlans)  }
#   - path: /etc/sysconfig/network/ifcfg-mgmt.${module.harvester_cluster.vlan_tags[i]}
#     owner: root:root
#     permissions: '0644'
#     content: |
#       ETHERDEVICE=mgmt-br
#       BOOTPROTO=dhcp
#       ONBOOT=yes
#       VLAN_ID=${module.harvester_cluster.vlan_tags[i]}
# %{ endfor }
#   EOT
}


data "equinix_metal_project" "project_id" {
  name = var.project_name
}

data "local_file" "harvester_kubeconfig" {
  filename = "${path.module}/../${var.hostname_prefix}${var.cluster_number}-rke2.yaml"

  depends_on = [ null_resource.kubeconfig ]
  
}

resource "null_resource" "kubeconfig" {


  provisioner "local-exec" {
    command = "NAME=${var.hostname_prefix}${var.cluster_number} IP=${module.harvester_cluster.public_ips[0]} SSH_PRIVATE_KEY_FILE=${var.ssh_private_key_file} ${path.module}/scripts/get_kubeconfig.sh"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm -f ../*.yaml ../*.txt"
  }
}

resource "null_resource" "set_password" {


  triggers = {
    harvester_url = module.harvester_cluster.harvester_url
  }

  provisioner "local-exec" {
    command = "HOST=${replace(replace(module.harvester_cluster.harvester_url,"https://", ""),"/","")} BOOTSTRAP_PASSWORD=${var.bootstrap_password} NEW_PASSWORD=${var.harvester_password} ${path.module}/scripts/set_password.sh"
  }

  depends_on = [null_resource.kubeconfig]
}


module "create_vcluster_namespace" {
  source          = "./modules/apply_manifest"
  kubeconfig_file = "${path.module}/../${var.hostname_prefix}${var.cluster_number}-rke2.yaml"
  manifest        = templatefile("${path.module}/templates/rancher-vcluster-namespace.yaml.tmpl", {})
  
  depends_on      = [null_resource.set_password]
}

module "create_vcluster" {

  source          = "./modules/apply_manifest"
  kubeconfig_file = "${path.module}/../${var.hostname_prefix}${var.cluster_number}-rke2.yaml"
  manifest = templatefile("${path.module}/templates/rancher-vcluster.yaml.tmpl", {
    rancher_hostname           = local.rancher_host
    rancher_bootstrap_password = var.rancher_bootstrap_password
    rancher_letsencrypt_email = var.rancher_letsencrypt_email
  })
  depends_on = [module.create_vcluster_namespace]
}

resource "null_resource" "set_password_rancher" {


  triggers = {
    rancher_host = local.rancher_host
  
  }

  provisioner "local-exec" {
    command = "HOST=${local.rancher_host} BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} NEW_PASSWORD=${var.rancher_password} ${path.module}/scripts/set_password_rancher.sh"
  }

  depends_on = [module.create_vcluster]
}

# data "external" "get_token" {
#   program = ["/bin/bash", "-c","HOST=${local.rancher_host} USERNAME=admin PASSWORD=${var.rancher_password} ${path.module}/scripts/get_token_rancher.sh"]

#   depends_on = [null_resource.set_password_rancher]
# }

data "http" "get_token" {

  insecure = true
  url = "https://${local.rancher_host}/v3-public/localProviders/local?action=login"
  request_body = "{\"username\": \"admin\", \"password\":\"${var.rancher_password}\"}"
  method = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }

  depends_on = [null_resource.set_password_rancher, module.harvester_cluster, cloudflare_record.dns_record_rancher]

}

resource "null_resource" "update_server_url" {
  
    triggers = {
    rancher_host = local.rancher_host
  
  }

  provisioner "local-exec" {
    command = "RANCHER_URL=https://${local.rancher_host} TOKEN=${jsondecode(data.http.get_token.response_body).token} ${path.module}/scripts/update_server_url.sh"

  }
}

module "import_harvester" {
  source          = "./modules/rancher_import_harvester"
  
  rancher_token = local.rancher_token
  rancher_url      = "https://${local.rancher_host}" 
  harvester_config_path = "${path.module}/../${var.hostname_prefix}${var.cluster_number}-rke2.yaml"
  depends_on = [ null_resource.update_server_url ]
}

# module "post_deploy" {
#   source = "../tf-hv-dhcpd-reqs"

#   ssh_key_name = var.ssh_key_name
#   ssh_public_key = var.ssh_public_key
#   additional_runcmd_data =  var.additional_runcmd_data
#   equinix_private_ipv4_subnets =  [ for i in range(var.num_of_vlans) : data.equinix_metal_reserved_ip_block.metal_gateway_subnet[i].cidr_notation ]
#   vlan_ids = [ for i in range(var.num_of_vlans) : module.harvester_cluster[0].vlan_id[i] ]
#   equinix_public_ipv4_subnet = data.equinix_metal_reserved_ip_block.public_subnet[0].cidr_notation
# }
