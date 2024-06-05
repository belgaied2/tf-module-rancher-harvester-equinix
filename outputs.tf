output "harvester_url" {
  value = module.harvester_cluster[*].harvester_url
}

#output "node_ip" {
#value = module.harvester_cluster[*].node_ip
#}

output "rancher_token" {
  value = data.external.get_token.result.token
}

output "rancher_url" {
  value =  "https://${local.rancher_host}"
}