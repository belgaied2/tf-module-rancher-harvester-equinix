module "harvester_cluster" {
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
}

resource "null_resource" "kubeconfig" {

  count = var.cluster_count

  provisioner "local-exec" {
    command = "NAME=bk-harvester-cl${count.index} IP=${module.harvester_cluster[count.index].public_ips[0]} SSH_PRIVATE_KEY_FILE=${var.ssh_private_key_file} scripts/get_kubeconfig.sh"
  }
}

resource "null_resource" "set_password" {

  count = var.cluster_count

  provisioner "local-exec" {
    command = "HOST=${module.harvester_cluster[count.index].public_ips[0]} BOOTSTRAP_PASSWORD=${var.bootstrap_password} NEW_PASSWORD=${var.harvester_password} scripts/set_password.sh"
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
    rancher_hostname           = format("rancher.%s.nip.io", module.harvester_cluster[count.index].public_ips[0]),
    rancher_bootstrap_password = var.rancher_bootstrap_password
  })
  depends_on = [module.create_vcluster_namespace]
}

resource "null_resource" "set_password_rancher" {

  count = var.cluster_count

  provisioner "local-exec" {
    command = "HOST=rancher.${module.harvester_cluster[count.index].public_ips[0]}.nip.io BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} NEW_PASSWORD=${var.rancher_password} scripts/set_password_rancher.sh"
  }

  depends_on = [module.create_vcluster]
}
#
# module "create_harvester_cluster" {
#   source          = "./modules/apply_manifest"
#   count           = var.cluster_count
#   kubeconfig_file = "${path.module}/../${var.hostname_prefix}${count.index}-rke2.yaml"
#   manifest        = templatefile("${path.module}/templates/harvester-cluster.yaml.tmpl", {})
#   depends_on      = [null_resource.set_password_rancher]
# }
