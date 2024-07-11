resource "github_branch" "participant_branch" {
  repository = var.github_participant_repo
  branch = var.participant_id
  
}

resource "github_repository_file" "README" {
  repository = var.github_participant_repo

  branch = var.participant_id
  overwrite_on_create = true
  commit_author = "Mohamed Belgaied"
  commit_email = "mohamed.belgaied@suse.com"
  commit_message = "Information file - generated"
  content = templatefile("${path.module}/templates/README.md.tmpl", {
    rancher_hostname = cloudflare_record.dns_record_rancher.hostname
    rancher_password = var.rancher_password
    node_ips = module.harvester_cluster.public_ips
    nodes_ssh_password = module.harvester_cluster.nodes_ssh_password
    node_count = var.node_count
    router_vm_public_ip = cidrhost(data.equinix_metal_reserved_ip_block.public_subnet.cidr_notation,5)
    harvester_vip = module.harvester_cluster.harvester_vip
  }) 
  file = "./README.md" 
}