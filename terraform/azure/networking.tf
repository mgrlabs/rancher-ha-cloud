################################
# Load Balancer
################################

# Load balancer
resource "azurerm_lb" "frontend" {
  name                = "${local.name_prefix}-lb"
  sku                 = "standard"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name

  frontend_ip_configuration {
    name                          = "rancher-lb-frontend"
    subnet_id                     = data.azurerm_subnet.rancher.id
    private_ip_address_allocation = "dynamic"
  }
  tags     = local.tags
}

# Private DNS record for load balancer internal IP
resource "azurerm_private_dns_a_record" "rancher_ha" {
  name                = "rancher"
  zone_name           = "${var.arm_location}.${var.environment}.${var.private_dns_zone_suffix}"
  resource_group_name = "${var.environment}-${var.arm_location}-private-dns-zone-rg"
  ttl                 = 300
  records             = [azurerm_lb.frontend.private_ip_address]
}

# Load balancer backend pool
resource "azurerm_lb_backend_address_pool" "frontend" {
  resource_group_name = azurerm_resource_group.rancher_ha.name
  loadbalancer_id     = azurerm_lb.frontend.id
  name                = "rancher-lb-backend"
}

resource "azurerm_network_interface_backend_address_pool_association" "worker" {
  count                   = var.node_count
  network_interface_id    = element(azurerm_network_interface.rancher_ha.*.id, count.index)
  ip_configuration_name   = "ip-configuration-rancher-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id
}

# Probe
resource "azurerm_lb_probe" "rancher_ha" {
  resource_group_name = azurerm_resource_group.rancher_ha.name
  loadbalancer_id     = azurerm_lb.frontend.id
  name                = "rancher-uptime-probe"
  protocol            = "Http"
  port                = "80"
  request_path        = "/healthz"
}

# Rancher HTTP
resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.rancher_ha.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "RancherHttpAccess"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "rancher-lb-frontend"
  probe_id                       = azurerm_lb_probe.rancher_ha.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
}

# Rancher HTTPS
resource "azurerm_lb_rule" "https" {
  resource_group_name            = azurerm_resource_group.rancher_ha.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "RancherHttpsAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  probe_id                       = azurerm_lb_probe.rancher_ha.id
  frontend_ip_configuration_name = "rancher-lb-frontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
}

# kubeapi
resource "azurerm_lb_rule" "kubeapi" {
  resource_group_name            = azurerm_resource_group.rancher_ha.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "kubeApiAccess"
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "rancher-lb-frontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
}

################################
# Node Network Security Group
################################

# https://rancher.com/docs/rancher/v2.x/en/installation/requirements/

resource "azurerm_network_security_group" "rancher_ha" {
  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name

  # SSH into nodes for support
  security_rule {
    name                       = "SSH"
    description                = "Inbound SSH Traffic"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Rancher UI/API when external SSL termination is used
  security_rule {
    name                       = "Canal-80"
    description                = "Inbound Canal Traffic"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Rancher agent, Rancher UI/API, kubectl
  security_rule {
    name                       = "Canal-443"
    description                = "Inbound Secure Canal Traffic"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # etcd
  security_rule {
    name                       = "etcd"
    description                = "Inbound etcd"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2379-2380"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Kubernetes apiserver
  security_rule {
    name                       = "KubernetesAPIServer"
    description                = "Inbound Kubenetes API"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Canal/Flannel VXLAN overlay networking
  security_rule {
    name                       = "CanalNetworking"
    description                = "Canal/Flannel VXLAN overlay networking"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "8472"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Canal/Flannel livenessProbe/readinessProbe
  security_rule {
    name                       = "CanalProbes"
    description                = "Canal/Flannel livenessProbe/readinessProbe"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9099"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # kubelet
  security_rule {
    name                       = "KubeletAPI"
    description                = "Inbound Kubelet API"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # NodePort port range
  security_rule {
    name                       = "NodePort-Services"
    description                = "NodePort port range"
    priority                   = 1009
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags     = local.tags
}
