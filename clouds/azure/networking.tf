################################
# Virtual Networking
################################

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "network" {
  name                = "vnet-rancher-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name
}

# Create subnets
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-rancher"
  resource_group_name  = azurerm_resource_group.rancher_ha.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "subnet-bastion"
  resource_group_name  = azurerm_resource_group.rancher_ha.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.10.0/27"]
}

################################
# Load Balancer
################################

# Nat rule for Bastion
resource "azurerm_lb_nat_rule" "bastion" {
  resource_group_name            = azurerm_resource_group.rancher_ha.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "sshBastion"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "rancher-lb-frontend"
}

resource "azurerm_network_interface_nat_rule_association" "bastion" {
  network_interface_id  = azurerm_network_interface.bastion.id
  ip_configuration_name = "ip-configuration-bastion-1"
  nat_rule_id           = azurerm_lb_nat_rule.bastion.id
}

# Public IP
resource "azurerm_public_ip" "frontend" {
  name                = "pip-rancher-lb-${var.environment}"
  sku                 = "standard"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name
  allocation_method   = "Static"
  domain_name_label   = "${var.company_prefix}rancher${var.environment}"
}

resource "azurerm_lb" "frontend" {
  name                = "lb-rancher-${var.environment}"
  sku                 = "standard"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name

  frontend_ip_configuration {
    name                 = "rancher-lb-frontend"
    public_ip_address_id = azurerm_public_ip.frontend.id
  }
}

resource "azurerm_lb_backend_address_pool" "frontend" {
  resource_group_name = azurerm_resource_group.rancher_ha.name
  loadbalancer_id     = azurerm_lb.frontend.id
  name                = "rancher-lb-backend"
}

resource "azurerm_network_interface_backend_address_pool_association" "worker" {
  count                   = var.k8s_node_count
  network_interface_id    = element(azurerm_network_interface.rancher_ha.*.id, count.index)
  ip_configuration_name   = "ip-configuration-rancher-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id
}

resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.rancher_ha.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "httpAccess"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "rancher-lb-frontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
}

resource "azurerm_lb_rule" "https" {
  resource_group_name            = azurerm_resource_group.rancher_ha.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "httpsAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
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
# NSG - K8s Nodes
################################

# https://rancher.com/docs/rancher/v2.x/en/installation/requirements/

resource "azurerm_network_security_group" "rancher_ha" {
  name                = "nsg-rancher-nodes-${var.environment}"
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
}

################################
# NSG - Bastion Node
################################

data "external" "whatismyip" {
  program = ["${path.root}/../scripts/what-is-my-ip.sh"]
}

resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-rancher-bastion-${var.environment}"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name

  security_rule {
    name                       = "SSH"
    description                = "Inbound SSH Traffic"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["${data.external.whatismyip.result["internet_ip"]}/32"]
    destination_address_prefix = "*"
  }
}
