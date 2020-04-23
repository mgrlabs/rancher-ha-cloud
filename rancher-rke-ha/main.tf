################################
# Azure RM Provider
################################

provider "azurerm" {
  version = "=2.6.0"

  subscription_id = var.azure_service_principal.subscription_id
  client_id       = var.azure_service_principal.client_id
  client_secret   = var.azure_service_principal.client_secret
  tenant_id       = var.azure_service_principal.tenant_id
  environment     = var.azure_service_principal.environment

  features {}
}

################################
# Resource Group
################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = var.azure_resource_group
  location = var.location
}
