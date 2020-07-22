################################
# Main
################################

# Resource group
resource "azurerm_resource_group" "rancher" {
  name     = "${var.environment}-${var.region}-rancher-rg"
  location = var.region

  tags = local.tags
}

# Data resources
data "azurerm_client_config" "current" {
}

data "azurerm_subnet" "rancher" {
  name                 = var.rancher_subnet
  virtual_network_name = "${var.environment}-${var.region}-vnet-rancher-vnet"
  resource_group_name  = "${var.environment}-${var.region}-vnet-rancher-rg"
}

# Rancher Common module
module rancher_common {
  source                                = "../rancher-common"
  azure_service_principal_client_id     = var.azure_service_principal_client_id
  azure_service_principal_client_secret = var.azure_service_principal_client_secret
  azure_tenant_id                       = data.azurerm_client_config.current.tenant_id
  azure_subscription_id                 = data.azurerm_client_config.current.subscription_id
  load_balancer_fqdn                    = trimsuffix(azurerm_private_dns_a_record.rancher.fqdn, ".")
  node_azure_names                      = azurerm_linux_virtual_machine.rancher.*.name
  node_ip_addresses                     = azurerm_network_interface.rancher.*.private_ip_address
  node_ssh_private_key                  = tls_private_key.ssh.private_key_pem
  load_balancer_private_ip              = azurerm_lb.rancher.private_ip_address
  linux_username                        = var.linux_username
  rke_depends_on                        = azurerm_virtual_machine_extension.rancher.*.id
}
