data "cloudflare_zone" "susecon_zone" {
  name = "susecon2024.work"
}

resource "cloudflare_record" "dns_record_rancher" {
  zone_id = data.cloudflare_zone.susecon_zone.id
  name = "rancher-${var.cluster_number}"
  type = "A"
  value = module.harvester_cluster.harvester_vip
  
}

