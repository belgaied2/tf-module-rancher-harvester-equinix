# Terraform Module for Harvester and Rancher on Equinix

## Introduction

This modules aims at simplifying the deployment of Harvester on top of Equinix Metal in an opinionated way, this includes:
- Deploying Rancher as vCluster inside Harvester
- Automatically importing Harvester as a Virtualization Cluster inside of Rancher
- Using Equinix Metal Gateways for VLAN-tagged subnets accessible by VMs

## Features




## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 4.34.0 |
| <a name="requirement_equinix"></a> [equinix](#requirement\_equinix) | 1.34.1 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.2.1 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.34.0 |
| <a name="provider_equinix"></a> [equinix](#provider\_equinix) | 1.34.1 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.2 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_create_vcluster"></a> [create\_vcluster](#module\_create\_vcluster) | ./modules/apply_manifest | n/a |
| <a name="module_create_vcluster_namespace"></a> [create\_vcluster\_namespace](#module\_create\_vcluster\_namespace) | ./modules/apply_manifest | n/a |
| <a name="module_harvester_cluster"></a> [harvester\_cluster](#module\_harvester\_cluster) | ./modules/terraform-harvester-equinix | n/a |
| <a name="module_import_harvester"></a> [import\_harvester](#module\_import\_harvester) | ./modules/rancher_import_harvester | n/a |

## Resources

| Name | Type |
|------|------|
| [cloudflare_record.dns_record_rancher](https://registry.terraform.io/providers/cloudflare/cloudflare/4.34.0/docs/resources/record) | resource |
| [equinix_metal_gateway.gateway_private_subnet](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/resources/metal_gateway) | resource |
| [equinix_metal_gateway.gateway_public_subnet](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/resources/metal_gateway) | resource |
| [equinix_metal_port_vlan_attachment.public_vlan_on_nodes](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/resources/metal_port_vlan_attachment) | resource |
| [equinix_metal_reserved_ip_block.public_ip_block_router](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/resources/metal_reserved_ip_block) | resource |
| [equinix_metal_vlan.public_vlan](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/resources/metal_vlan) | resource |
| [github_branch.participant_branch](https://registry.terraform.io/providers/integrations/github/6.2.1/docs/resources/branch) | resource |
| [github_repository_file.README](https://registry.terraform.io/providers/integrations/github/6.2.1/docs/resources/repository_file) | resource |
| [null_resource.kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.set_password](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.set_password_rancher](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.update_server_url](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [cloudflare_zone.susecon_zone](https://registry.terraform.io/providers/cloudflare/cloudflare/4.34.0/docs/data-sources/zone) | data source |
| [equinix_metal_gateway.get_ip_id_from_gateway](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/data-sources/metal_gateway) | data source |
| [equinix_metal_gateway.get_ip_id_from_gateway_public](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/data-sources/metal_gateway) | data source |
| [equinix_metal_project.project_id](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/data-sources/metal_project) | data source |
| [equinix_metal_reserved_ip_block.metal_gateway_subnet](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/data-sources/metal_reserved_ip_block) | data source |
| [equinix_metal_reserved_ip_block.public_subnet](https://registry.terraform.io/providers/equinix/equinix/1.34.1/docs/data-sources/metal_reserved_ip_block) | data source |
| [http_http.get_token](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [local_file.harvester_kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_token"></a> [auth\_token](#input\_auth\_token) | Equinix API authentication token | `string` | `""` | no |
| <a name="input_bootstrap_password"></a> [bootstrap\_password](#input\_bootstrap\_password) | Bootstrap password for admin | `string` | `"admin"` | no |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API Token | `string` | n/a | yes |
| <a name="input_cluster_number"></a> [cluster\_number](#input\_cluster\_number) | Cluster number | `number` | n/a | yes |
| <a name="input_github_participant_repo"></a> [github\_participant\_repo](#input\_github\_participant\_repo) | GitHub Repository for the participant | `string` | n/a | yes |
| <a name="input_harvester_password"></a> [harvester\_password](#input\_harvester\_password) | Password for harvester admin user | `string` | n/a | yes |
| <a name="input_harvester_version"></a> [harvester\_version](#input\_harvester\_version) | Version of Harvester to deploy | `string` | `"v1.2.1"` | no |
| <a name="input_hostname_prefix"></a> [hostname\_prefix](#input\_hostname\_prefix) | hostname prefix | `string` | `"harvester-cl"` | no |
| <a name="input_metro"></a> [metro](#input\_metro) | Metro to deploy the Harvester cluster | `string` | `"FR"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of nodes in the Harvester cluster | `number` | `1` | no |
| <a name="input_num_of_vlans"></a> [num\_of\_vlans](#input\_num\_of\_vlans) | Number of VLANs to create | `number` | `1` | no |
| <a name="input_participant_id"></a> [participant\_id](#input\_participant\_id) | Participant ID, mostly used for GitHub Branch and Rancher Hostname Suffix | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to create the Harvester cluster | `string` | `"test"` | no |
| <a name="input_rancher_access_key"></a> [rancher\_access\_key](#input\_rancher\_access\_key) | Rancher access key | `string` | `""` | no |
| <a name="input_rancher_api_url"></a> [rancher\_api\_url](#input\_rancher\_api\_url) | Rancher API endpoint to manager your Harvester cluster | `string` | `""` | no |
| <a name="input_rancher_bootstrap_password"></a> [rancher\_bootstrap\_password](#input\_rancher\_bootstrap\_password) | Rancher Bootstrap Password | `string` | `"Rancher1234-"` | no |
| <a name="input_rancher_insecure"></a> [rancher\_insecure](#input\_rancher\_insecure) | Allow insecure connections to the Rancher API | `bool` | `false` | no |
| <a name="input_rancher_letsencrypt_email"></a> [rancher\_letsencrypt\_email](#input\_rancher\_letsencrypt\_email) | Email to use for Let's Encrypt | `string` | n/a | yes |
| <a name="input_rancher_password"></a> [rancher\_password](#input\_rancher\_password) | Rancher Password for Admin User | `string` | n/a | yes |
| <a name="input_rancher_secret_key"></a> [rancher\_secret\_key](#input\_rancher\_secret\_key) | Rancher secret key | `string` | `""` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | SSH key to use for the Harvester cluster | `string` | `""` | no |
| <a name="input_ssh_private_key_file"></a> [ssh\_private\_key\_file](#input\_ssh\_private\_key\_file) | Path to private key file for Harvester Host | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_private_subnet"></a> [gateway\_private\_subnet](#output\_gateway\_private\_subnet) | n/a |
| <a name="output_gateway_public_subnet"></a> [gateway\_public\_subnet](#output\_gateway\_public\_subnet) | n/a |
| <a name="output_harvester_url"></a> [harvester\_url](#output\_harvester\_url) | n/a |
| <a name="output_node_ips"></a> [node\_ips](#output\_node\_ips) | n/a |
| <a name="output_nodes_ssh_password"></a> [nodes\_ssh\_password](#output\_nodes\_ssh\_password) | n/a |
| <a name="output_rancher_token"></a> [rancher\_token](#output\_rancher\_token) | n/a |
| <a name="output_rancher_url"></a> [rancher\_url](#output\_rancher\_url) | n/a |
| <a name="output_vlan_ids"></a> [vlan\_ids](#output\_vlan\_ids) | n/a |
