################################
# Load Balancer - Rancher HA
################################

# Nat rule for Bastion
resource "azurerm_lb_nat_rule" "bastion" {
  resource_group_name            = azurerm_resource_group.resourcegroup.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "sshBastion"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "rke-lb-frontend"
}

resource "azurerm_network_interface_nat_rule_association" "bastion" {
  network_interface_id  = azurerm_network_interface.bastion.id
  ip_configuration_name = "ip-configuration-bastion-1"
  nat_rule_id           = azurerm_lb_nat_rule.bastion.id
}

# Public IP
resource "azurerm_public_ip" "frontend" {
  name                = "pip-lb-rancher"
  sku                 = "standard"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  domain_name_label   = var.loadbalancer_dns_prefix
}

resource "azurerm_lb" "frontend" {
  name                = "lb-rancher"
  sku                 = "standard"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  frontend_ip_configuration {
    name                 = "rke-lb-frontend"
    public_ip_address_id = azurerm_public_ip.frontend.id
  }
}

resource "azurerm_lb_backend_address_pool" "frontend" {
  resource_group_name = azurerm_resource_group.resourcegroup.name
  loadbalancer_id     = azurerm_lb.frontend.id
  name                = "rke-lb-backend"
}

resource "azurerm_network_interface_backend_address_pool_association" "worker" {
  count                   = var.rke_node_count
  network_interface_id    = element(azurerm_network_interface.rke.*.id, count.index)
  ip_configuration_name   = "ip-configuration-rke-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id
}

# http
# resource "azurerm_lb_probe" "http" {
#   resource_group_name = azurerm_resource_group.resourcegroup.name
#   loadbalancer_id     = azurerm_lb.frontend.id
#   name                = "http-running-probe"
#   port                = 80
# }

resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.resourcegroup.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "httpAccess"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "rke-lb-frontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
}

# https
# resource "azurerm_lb_probe" "https" {
#   resource_group_name = azurerm_resource_group.resourcegroup.name
#   loadbalancer_id     = azurerm_lb.frontend.id
#   name                = "https-running-probe"
#   port                = 443
# }

resource "azurerm_lb_rule" "https" {
  resource_group_name            = azurerm_resource_group.resourcegroup.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "httpsAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "rke-lb-frontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
}

# kubeapi
resource "azurerm_lb_rule" "kubeapi" {
  resource_group_name            = azurerm_resource_group.resourcegroup.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "kubeApiAccess"
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "rke-lb-frontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
}
