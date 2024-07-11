output "harvester_url" {
  value = module.harvester_cluster.harvester_url
}

# output "node_ip" {
# value = module.harvester_cluster[*].node_ip
# }

output "rancher_token" {
  value = data.http.get_token
}

output "rancher_url" {
  value =  local.rancher_host 
}

output "gateway_public_subnet" {
  value = data.equinix_metal_reserved_ip_block.public_subnet.cidr_notation
}

output "gateway_private_subnet" {
  value = data.equinix_metal_reserved_ip_block.metal_gateway_subnet[*].cidr_notation
}

output "vlan_ids" {
  value = module.harvester_cluster.vlan_tags
}

output "node_ips" {
  value = module.harvester_cluster.public_ips
  
}

output "nodes_ssh_password" {
  value = module.harvester_cluster.nodes_ssh_password
}