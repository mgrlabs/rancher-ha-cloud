locals {
  azure_prefix   = "${var.environment}-${var.region}-${var.product}-rke"
  rancher_prefix = "${var.product}-${var.environment}-${var.region}"
  vnet_prefix    = "${var.environment}-${var.region}-${var.product}-vnet"

  rancher_api_url         = "https://rancher.${var.rancher_region}.${var.environment}.${local.private_dns_zone_suffix}"
  private_dns_zone_suffix = "arkoselabs.internal"
  tags                    = merge(var.tags, local.module_tags)
  module_tags = {
    "Module" = "rancher-clusters"
  }
}
