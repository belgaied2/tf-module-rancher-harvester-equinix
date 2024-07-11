## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.2 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hv_set_registration_token"></a> [hv\_set\_registration\_token](#module\_hv\_set\_registration\_token) | ../apply_manifest | n/a |

## Resources

| Name | Type |
|------|------|
| [time_sleep.wait_get_cluster_object](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [http_http.create_imported_harvester](https://registry.terraform.io/providers/hashicorp/http/3.4.2/docs/data-sources/http) | data source |
| [http_http.get_cluster_object](https://registry.terraform.io/providers/hashicorp/http/3.4.2/docs/data-sources/http) | data source |
| [http_http.get_registration_token](https://registry.terraform.io/providers/hashicorp/http/3.4.2/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_harvester_config_path"></a> [harvester\_config\_path](#input\_harvester\_config\_path) | path to harvester config file | `string` | n/a | yes |
| <a name="input_rancher_token"></a> [rancher\_token](#input\_rancher\_token) | value of the rancher API Token | `string` | n/a | yes |
| <a name="input_rancher_url"></a> [rancher\_url](#input\_rancher\_url) | prefix of the hostname | `string` | n/a | yes |

## Outputs

No outputs.
