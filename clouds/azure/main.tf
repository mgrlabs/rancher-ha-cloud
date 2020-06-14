################################
# Resource Group
################################

resource "azurerm_resource_group" "rancher_ha" {
  name     = "${var.environment}-rancher-rg"
  location = var.arm_location
}
