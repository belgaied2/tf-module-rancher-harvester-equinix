data "cloudflare_zone" "susecon_zone" {
  name = "susecon2024.work"
}

resource "cloudflare_record" "dns_record_rancher" {
  count = var.cluster_count
  zone_id = data.cloudflare_zone.susecon_zone.id
  name = "rancher-${count.index + 1}"
  type = "A"
  value = module.harvester_cluster[count.index].harvester_vip
  
}

