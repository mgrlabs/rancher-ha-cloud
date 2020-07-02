locals {
  name_prefix = "${var.environment}-${local.region_abbr[var.arm_location]}-rancher-node"
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
}