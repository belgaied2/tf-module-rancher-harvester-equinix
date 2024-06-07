resource "equinix_metal_gateway" "gateway_private_subnet" {

  count = var.cluster_count * var.num_of_vlans

  project_id = data.equinix_metal_project.project_id.id
  private_ipv4_subnet_size = 128
  vlan_id = module.harvester_cluster[count.index / var.num_of_vlans].vlan_id[ count.index % var.num_of_vlans ]

}

data "equinix_metal_gateway" "get_ip_id_from_gateway" {
  count = var.cluster_count * var.num_of_vlans

  gateway_id = equinix_metal_gateway.gateway_private_subnet[count.index].id

}


data "equinix_metal_reserved_ip_block" "metal_gateway_subnet" {
  count = var.cluster_count * var.num_of_vlans

  id = data.equinix_metal_gateway.get_ip_id_from_gateway[count.index].ip_reservation_id
}

resource "equinix_metal_reserved_ip_block" "public_ip_block_router" {
  count =  var.cluster_count

  project_id = data.equinix_metal_project.project_id.id
  metro = var.metro
  type = "public_ipv4"
  quantity = 8

}

resource "equinix_metal_vlan" "public_vlan" {
  count = var.cluster_count

  project_id = data.equinix_metal_project.project_id.id
  metro = var.metro
  description = "Public VLAN for Router"
  vxlan = count.index + 250 
}

resource "equinix_metal_gateway" "gateway_public_subnet" {
  count = var.cluster_count

  project_id = data.equinix_metal_project.project_id.id
  ip_reservation_id = equinix_metal_reserved_ip_block.public_ip_block_router[count.index].id 
  vlan_id = equinix_metal_vlan.public_vlan[count.index].id
  
}

resource "equinix_metal_port_vlan_attachment" "public_vlan_on_nodes" {
  count = var.cluster_count * var.node_count

  port_name = "bond0"
  vlan_vnid = equinix_metal_vlan.public_vlan[count.index / var.node_count].vxlan
  device_id = module.harvester_cluster[count.index / var.node_count].nodes[count.index % var.node_count]

}

data "equinix_metal_gateway" "get_ip_id_from_gateway_public" {
  count = var.cluster_count 

  gateway_id = equinix_metal_gateway.gateway_public_subnet[count.index].id

}


data "equinix_metal_reserved_ip_block" "public_subnet" {
  count = var.cluster_count 

  id = data.equinix_metal_gateway.get_ip_id_from_gateway_public[count.index].ip_reservation_id
}