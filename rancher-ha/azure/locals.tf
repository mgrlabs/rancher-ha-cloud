################################
# Locals
################################

locals {
  tags = merge(var.tags, local.module_tags)
  module_tags = {
    "Module" = "rancher-ha-cloud"
  }
  name_prefix = "${var.environment}-${var.region}-rancher"
  private_dns_zone_suffix = "arkoselabs.internal"
}
