################################
# Resource Group
################################

resource "azurerm_resource_group" "rancher_cluster" {
  name     = "rg-${var.company_prefix}-rancher-${var.environment}"
  location = var.arm_location
}
