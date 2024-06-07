output "harvester_url" {
  value = module.harvester_cluster[*].harvester_url
}

#output "node_ip" {
#value = module.harvester_cluster[*].node_ip
#}

output "rancher_token" {
  value = [ for token_response in data.http.get_token : jsondecode(token_response.response_body).token ]
}

output "rancher_url" {
  value =  [ for host in local.rancher_host : "https://${host}" ]
}

output "gateway_public_subnet" {
  value = data.equinix_metal_reserved_ip_block.public_subnet[*].cidr_notation
}

output "gateway_private_subnet" {
  value = data.equinix_metal_reserved_ip_block.metal_gateway_subnet[*].cidr_notation
}