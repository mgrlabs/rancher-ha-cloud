################################
# Resource Group
################################

resource "azurerm_resource_group" "rancher_ha" {
  name     = "rg-rancher-${var.environment}"
  location = var.arm_location
}
