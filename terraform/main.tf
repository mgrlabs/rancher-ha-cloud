################################
# Azure RM Provider
################################

provider "azurerm" {
  version = "=2.8.0"
  features {}
}

################################
# Resource Group
################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "rg-${var.company_prefix}-rancher-${var.environment}"
  location = var.arm_location
}

data "external" "whatismyip" {
  program = ["${path.module}/../scripts/whatismyip.sh"]
}