data "http" "create_imported_harvester" {
  url = "${var.rancher_url}/v1/provisioning.cattle.io.clusters"

  method = "POST"
  request_headers = {
    "Authorization" = "Bearer ${var.rancher_token}"
  }
  request_body = "{\"type\":\"provisioning.cattle.io.cluster\",\"metadata\":{\"namespace\":\"fleet-default\",\"name\":\"harvester\",\"labels\":{\"provider.cattle.io\":\"harvester\"}},\"cachedHarvesterClusterVersion\":\"\",\"spec\":{\"agentEnvVars\":[]}}"
  insecure = true
}

resource "time_sleep" "wait_get_cluster_object" {
  depends_on = [data.http.create_imported_harvester]
  create_duration = "10s"
  
}

data "http" "get_cluster_object" {
  url = "${var.rancher_url}/v3/clusters?name=harvester"

  method = "GET"
  request_headers = {
    "Authorization" = "Bearer ${var.rancher_token}"
  }
  insecure = true
  depends_on = [ time_sleep.wait_get_cluster_object ]
}


data "http" "get_registration_token" {
  url = "${var.rancher_url}/v3/clusterregistrationtokens?clusterId=${local.hv_cluster_id}"

  method = "GET"
  request_headers = {
    "Authorization" = "Bearer ${var.rancher_token}"
  }
  insecure = true
  depends_on = [ data.http.create_imported_harvester ]
}

locals {
  registration_token_response = jsondecode(data.http.get_registration_token.response_body)
  cluster_registration_url = length(local.registration_token_response.data) == 0 ? "" : local.registration_token_response.data[0].manifestUrl
  cluster_response = jsondecode(data.http.get_cluster_object.response_body)
  hv_cluster_id = length(local.cluster_response.data) == 0 ? "" : local.cluster_response.data[0].id

}

module "hv_set_registration_token" {
  source = "../apply_manifest"
  kubeconfig_file = var.harvester_config_path
  manifest = templatefile("${path.module}/templates/harvester-set-registration-token.yaml.tmpl", {
    cluster_registration_url = local.cluster_registration_url,
  })
  
}