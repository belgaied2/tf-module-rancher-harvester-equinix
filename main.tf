module "harvester_cluster" {
  count = 1
  source = "../harvester-equinix-terraform"
  harvester_version = "v1.2.1"
  node_count = var.node_count
  project_name = var.project_name
  metro = var.metro
  ssh_key=var.ssh_key
  hostname_prefix = "harvester-cl${count.index}"
  spot_instance = true
  max_bid_price = 0.15
  plan = "m3.small.x86"
}

