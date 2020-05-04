################################
# Virtual Networking
################################

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "network" {
  name                = "vnet-rancher-rke-ha"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

# Create subnets
resource "azurerm_subnet" "subnet" {
  name                            = "subnet-rke"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "bastion" {
  name                 = "subnet-bastion"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefix       = "10.0.10.0/27"
}
