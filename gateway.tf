resource "equinix_metal_gateway" "gateway_private_subnet" {

  count = var.num_of_vlans

  project_id = data.equinix_metal_project.project_id.id
  private_ipv4_subnet_size = 128
  vlan_id = module.harvester_cluster[var.num_of_vlans].vlan_id[ count.index  ]

}

data "equinix_metal_gateway" "get_ip_id_from_gateway" {
  count = var.num_of_vlans

  gateway_id = equinix_metal_gateway.gateway_private_subnet[count.index].id

}


data "equinix_metal_reserved_ip_block" "metal_gateway_subnet" {
  count = var.num_of_vlans

  id = data.equinix_metal_gateway.get_ip_id_from_gateway[count.index].ip_reservation_id
}

resource "equinix_metal_reserved_ip_block" "public_ip_block_router" {

  project_id = data.equinix_metal_project.project_id.id
  metro = var.metro
  type = "public_ipv4"
  quantity = 8

}

resource "equinix_metal_vlan" "public_vlan" {

  project_id = data.equinix_metal_project.project_id.id
  metro = var.metro
  description = "Public VLAN for Router"
  vxlan = var.cluster_number + 250 
}

resource "equinix_metal_gateway" "gateway_public_subnet" {

  project_id = data.equinix_metal_project.project_id.id
  ip_reservation_id = equinix_metal_reserved_ip_block.public_ip_block_router.id 
  vlan_id = equinix_metal_vlan.public_vlan.id
  
}

resource "equinix_metal_port_vlan_attachment" "public_vlan_on_nodes" {
  count = var.node_count

  port_name = "bond0"
  vlan_vnid = equinix_metal_vlan.public_vlan.vxlan
  device_id = module.harvester_cluster.nodes[count.index ]

}

data "equinix_metal_gateway" "get_ip_id_from_gateway_public" {

  gateway_id = equinix_metal_gateway.gateway_public_subnet.id

}


data "equinix_metal_reserved_ip_block" "public_subnet" {

  id = data.equinix_metal_gateway.get_ip_id_from_gateway_public.ip_reservation_id
}