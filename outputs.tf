output "harvester_url" {
  value = module.harvester_cluster[*].harvester_url
}

#output "node_ip" {
  #value = module.harvester_cluster[*].node_ip 
#}