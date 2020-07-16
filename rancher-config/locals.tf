locals {
  rancher_api_url         = "https://rancher.${var.rancher_region}.${var.environment}.${local.private_dns_zone_suffix}"
  private_dns_zone_suffix = "arkoselabs.internal"
}