################################
# Rancher & Bastion Nodes
################################

# RSA PKE for authentication
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "local_file" "ssh_private" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.root}/ssh_private_key"
}

################################
# Nodes - Rancher
################################

# Availability Set
resource "azurerm_availability_set" "rancher" {
  name                        = "as-${var.company_prefix}-rancher-${var.environment}"
  location                    = azurerm_resource_group.rancher_cluster.location
  resource_group_name         = azurerm_resource_group.rancher_cluster.name
  platform_fault_domain_count = 2
}

# Data Disk
resource "azurerm_managed_disk" "rancher" {
  count                = var.k8s_node_count
  name                 = "disk-${var.company_prefix}-rancher-data-${var.environment}-${count.index}"
  location             = azurerm_resource_group.rancher_cluster.location
  resource_group_name  = azurerm_resource_group.rancher_cluster.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

# Network Card
resource "azurerm_network_interface" "rancher" {
  count               = var.k8s_node_count
  name                = "nic-${var.company_prefix}-rancher-${var.environment}-${count.index}"
  location            = azurerm_resource_group.rancher_cluster.location
  resource_group_name = azurerm_resource_group.rancher_cluster.name

  ip_configuration {
    name                          = "ip-configuration-rancher-${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "rancher" {
  count                     = var.k8s_node_count
  network_interface_id      = element(azurerm_network_interface.rancher.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.rancher.id
}

# Virtual Machine
resource "azurerm_virtual_machine" "rancher" {
  count                            = var.k8s_node_count
  availability_set_id              = azurerm_availability_set.rancher.id
  name                             = "node-${var.company_prefix}-rancher-${var.environment}-${count.index}"
  location                         = azurerm_resource_group.rancher_cluster.location
  resource_group_name              = azurerm_resource_group.rancher_cluster.name
  network_interface_ids            = [element(azurerm_network_interface.rancher.*.id, count.index)]
  vm_size                          = var.k8s_node_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.k8s_ubuntu_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "disk-${var.company_prefix}-rancher-os-${var.environment}-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.rancher.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.rancher.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.rancher.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "node-${var.company_prefix}-rancher-${var.environment}-${count.index}"
    admin_username = var.admin_name
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_name}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://releases.rancher.com/install-docker/${var.k8s_docker_version}.sh | sh && sudo usermod -a -G docker ${var.admin_name}",
    ]

    connection {
      host        = azurerm_network_interface.rancher[count.index].private_ip_address
      type        = "ssh"
      user        = var.admin_name
      private_key = tls_private_key.ssh.private_key_pem

      bastion_host        = azurerm_public_ip.frontend.ip_address
      bastion_user        = var.admin_name
      bastion_private_key = tls_private_key.ssh.private_key_pem
    }
  }
  depends_on = [azurerm_virtual_machine.bastion]
}

################################
# Node - Bastion
################################

resource "azurerm_availability_set" "bastion" {
  name                        = "as-${var.company_prefix}-bastion-${var.environment}"
  location                    = azurerm_resource_group.rancher_cluster.location
  resource_group_name         = azurerm_resource_group.rancher_cluster.name
  platform_fault_domain_count = 2
}

# Network Interface
resource "azurerm_network_interface" "bastion" {
  name                = "nic-${var.company_prefix}-bastion-${var.environment}-1"
  location            = azurerm_resource_group.rancher_cluster.location
  resource_group_name = azurerm_resource_group.rancher_cluster.name

  ip_configuration {
    name      = "ip-configuration-bastion-1"
    subnet_id = azurerm_subnet.bastion.id
    private_ip_address_allocation = "dynamic"
  }
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

# Virtual Machine
resource "azurerm_virtual_machine" "bastion" {
  name                             = "bastion-${var.company_prefix}-${var.environment}-1"
  availability_set_id              = azurerm_availability_set.bastion.id
  location                         = azurerm_resource_group.rancher_cluster.location
  resource_group_name              = azurerm_resource_group.rancher_cluster.name
  network_interface_ids            = [azurerm_network_interface.bastion.id]
  vm_size                          = var.bastion_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "disk-${var.company_prefix}-bastion-os-${var.environment}-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "bastion-${var.company_prefix}-${var.environment}-1"
    admin_username = var.admin_name
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_name}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  provisioner "file" {
    content = tls_private_key.ssh.private_key_pem
    destination = "/home/${var.admin_name}/.ssh/id_rsa"

    connection {
      host = azurerm_public_ip.frontend.ip_address
      type        = "ssh"
      user        = var.admin_name
      private_key = tls_private_key.ssh.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/${var.admin_name}/.ssh/id_rsa",
    ]

    connection {
      host = azurerm_public_ip.frontend.ip_address
      type        = "ssh"
      user        = var.admin_name
      private_key = tls_private_key.ssh.private_key_pem
    }
  }
  depends_on = [azurerm_lb.frontend]
}
