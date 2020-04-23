provider "azurerm" {
  # version = "=2.6.0"

  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "mgr-aks-cluster"
  location = "Australia East"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-mgrlabs-test"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "mgrakstest"

  network_profile {
    load_balancer_sku = "standard"
    network_plugin = "azure"
  }

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}
