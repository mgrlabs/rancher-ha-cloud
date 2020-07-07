################################
# Resource Group
################################

resource "azurerm_resource_group" "rancher_ha" {
  name     = "${var.environment}-${var.arm_location}-rancher-rg"
  location = var.arm_location
}

# Data

data "azurerm_client_config" "current" {
}

data "azurerm_subnet" "rancher" {
  name                 = var.rancher_subnet
  virtual_network_name = "${var.environment}-${var.arm_location}-rancher-vnet"
  resource_group_name  = "${var.environment}-${var.arm_location}-rancher-vnet-rg"
}

################################
# Locals
################################

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

# Rancher Common
module rancher_common {
  source = "../rancher-common"
  service_principal_client_id = var.service_principal_client_id
  service_principal_client_secret = var.service_principal_client_secret
  service_principal_tenant_id = data.azurerm_client_config.current.tenant_id
  service_principal_subscription_id = data.azurerm_client_config.current.subscription_id
  load_balancer_fqdn = trimsuffix(azurerm_private_dns_a_record.rancher_ha.fqdn, ".")
  node_azure_names = azurerm_linux_virtual_machine.rancher_ha.*.name
  node_ip_addresses = azurerm_network_interface.rancher_ha.*.private_ip_address
  node_ssh_private_key = tls_private_key.ssh.private_key_pem
  load_balancer_private_ip = azurerm_lb.frontend.private_ip_address
  linux_username = var.linux_username
}
