
#resource "rancher2_cluster_v2" "harvester" {
  #name = "harvester"
  #labels = {
    #"provider.cattle.io" = "harvester"
  #}
  #kubernetes_version = "v1.25.9+rke2r1"
  #agent_env_vars {
    #name = "CATTLE_AGENT_CONNECT"
    #value = "true"
  #}

#}


data "http" "create_imported_harvester" {
  url = "${var.rancher_url}/v1/provisioning.cattle.io.clusters"

  method = "POST"
  request_headers = {
    "Authorization" = "Bearer ${var.rancher_token}"
  }
  request_body = "{\"type\":\"provisioning.cattle.io.cluster\",\"metadata\":{\"namespace\":\"fleet-default\",\"name\":\"harvester\",\"labels\":{\"provider.cattle.io\":\"harvester\"}},\"cachedHarvesterClusterVersion\":\"\",\"spec\":{\"agentEnvVars\":[]}}"
  insecure = true
}

data "http" "get_cluster_object" {
  url = "${var.rancher_url}/v3/clusters?name=harvester"

  method = "GET"
  request_headers = {
    "Authorization" = "Bearer ${var.rancher_token}"
  }
  insecure = true
  depends_on = [ data.http.create_imported_harvester ]
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
  registration_token_object = jsondecode(data.http.get_registration_token.response_body).data[0]
  cluster_registration_url = local.registration_token_object.manifestUrl != "" ? local.registration_token_object.manifestUrl : "${var.rancher_url}/v3/import/${local.registration_token_object.token}_${local.registration_token_object.clusterId}.yaml"
  hv_cluster_id = jsondecode(data.http.get_cluster_object.response_body).data[0].id
}

module "hv_set_registration_token" {
  source = "../apply_manifest"
  kubeconfig_file = var.harvester_config_path
  manifest = templatefile("${path.module}/templates/harvester-set-registration-token.yaml.tmpl", {
    cluster_registration_url = local.cluster_registration_url,
  })
  
}