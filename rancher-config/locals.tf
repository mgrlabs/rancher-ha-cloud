locals {
  rancher_api_url         = "https://rancher.${var.rancher_region}.${var.environment}.${local.private_dns_zone_suffix}"
  private_dns_zone_suffix = "arkoselabs.internal"

  # azure_node_templates = [for a in setproduct(var.regions, var.azure_node_sizes) : {
  #   template_name        = "${var.product}-${var.environment}-${a[0].region}-${a[1].node_role}",
  #   node_prefix          = "${var.environment}-${a[0].region}-${var.product}-rke",
  #   vnet_prefix          = "${var.environment}-${a[0].region}-vnet-spoke",
  #   subnet_prefix        = a[0].subnet_cidr
  #   subnet_name          = a[0].subnet_name
  #   region               = a[0].region
  #   fault_update_domains = a[0].fault_update_domains
  #   node_size            = a[1].node_vm_size
  #   node_role            = a[1].node_role
  #   node_disk_size       = a[1].node_disk_size
  #   node_storage_type    = a[1].node_storage_type
  # }]
}