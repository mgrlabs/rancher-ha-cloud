locals {
  rancher_api_url         = "https://rancher.${var.rancher_region}.${var.environment}.${local.private_dns_zone_suffix}"
  private_dns_zone_suffix = "arkoselabs.internal"

  # Azure specific
  region_abbr = {
    australiacentral   = "auce"
    australiacentral2  = "auc2"
    australiaeast      = "auea"
    australiasoutheast = "ause"
    centralus          = "usce"
    eastasia           = "asea"
    eastus             = "usea"
    eastus2            = "use2"
    northcentralus     = "usnc"
    northeurope        = "euno"
    southcentralus     = "ussc"
    southeastasia      = "assw"
    uksouth            = "ukso"
    ukwest             = "ukwe"
    westcentralus      = "uswc"
    westeurope         = "euwe"
    westus             = "uswe"
    westus2            = "usw2"
  }

  azure_node_templates = [for a in setproduct(var.regions, var.azure_node_sizes) : {
    template_name        = "${var.cloud}-${var.environment}-${a[0].region}-${a[1].node_size_name}",
    node_prefix          = "${var.environment}-${a[0].region}-rkecluster-${a[1].node_size_name}",
    vnet_prefix          = "${var.environment}-${a[0].region}-vnet-spoke",
    subnet_prefix        = a[0].subnet_cidr
    subnet_name          = a[0].subnet_name
    region               = a[0].region
    fault_update_domains = a[0].fault_update_domains
    template_name_short  = a[1].node_size_name
    node_size            = a[1].node_vm_size
    node_disk_size       = a[1].node_disk_size
    node_storage_type    = a[1].node_storage_type
  }]
}