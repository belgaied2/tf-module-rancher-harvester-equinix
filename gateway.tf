resource "equinix_metal_gateway" "gateway_private_subnet" {

  count = var.num_of_vlans

  project_id = data.equinix_metal_project.project_id.id
  private_ipv4_subnet_size = 128
  vlan_id = module.harvester_cluster.vlan_ids[ count.index  ]

}

data "equinix_metal_gateway" "get_ip_id_from_gateway" {
  count = var.num_of_vlans

  gateway_id = equinix_metal_gateway.gateway_private_subnet[count.index].id

}


data "equinix_metal_reserved_ip_block" "metal_gateway_subnet" {
  count = var.num_of_vlans

  id = data.equinix_metal_gateway.get_ip_id_from_gateway[count.index].ip_reservation_id
}

# locals {
#   private_cidrs = data.equinix_metal_reserved_ip_block.metal_gateway_subnet[*].cidr_notation
#   private_vlans = module.harvester_cluster.vlan_tags
# }

# resource "null_resource" "add_vlans_to_nodes" {
#   count = var.node_count * var.num_of_vlans

#   triggers = {
#     vlans = local.private_vlans
#     cidrs = local.private_cidrs
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "cat <<EOF VLAN_ID=${local.private_vlans[count.index % var.node_count]} >> /etc/sysconfig/network-scripts/ifcfg-eth1.${local.private_vlans[count.index % var.node_count]}"
#     ]  
#   }
  
# }

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
  vlan_id = equinix_metal_port_vlan_attachment.public_vlan_on_nodes[0].vlan_id
  
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

# locals {
#   interfaces = [ for i in range(0, var.num_of_vlans) : "eth1.${module.harvester_cluster.vlan_tags[i]}" ]

# }

# resource "null_resource" "configure_gateways" {
#   count = var.node_count * var.num_of_vlans

#   depends_on = [ equinix_metal_port_vlan_attachment.public_vlan_on_nodes, null_resource.set_password ]


#   provisioner "file" {
#     destination = "/home/rancher/ifcfg-${local.interfaces[count.index % var.num_of_vlans]}"
#     connection {
#       type     = "ssh"
#       user     = "rancher"
#       private_key = file("/home/mohamed/.ssh/id_rsa")
#       host     = module.harvester_cluster.public_ips[count.index / var.num_of_vlans]
#     }

#     content = <<-EOT
#       ETHERDEVICE=mgmt-br
#       VLAN_ID=${module.harvester_cluster.vlan_tags[count.index % var.num_of_vlans]}
#       BOOTPROTO=static
#       STARTMODE=auto
#       IPADDR=${cidrhost(data.equinix_metal_reserved_ip_block.metal_gateway_subnet[count.index % var.num_of_vlans].cidr_notation, 2)}
#       NETMASK=${data.equinix_metal_reserved_ip_block.metal_gateway_subnet[count.index % var.num_of_vlans].netmask}
#       EOT
#   }

#   provisioner "remote-exec" {
#     connection {
#       type     = "ssh"
#       user     = "rancher"
#       private_key = file("/home/mohamed/.ssh/id_rsa")
#       host     = module.harvester_cluster.public_ips[count.index / var.num_of_vlans]
#     }
#     inline = [
#       for interface in local.interfaces :  "sudo cp ~/ifcfg-${interface} /etc/sysconfig/network/ifcfg-${interface} && sudo wicked ifup ${interface}"
#     ] 
#   }
# }