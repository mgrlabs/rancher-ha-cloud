################################
# SSH Key
################################

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "local_file" "ssh_private" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.module}/ssh_private_key"
}

################################
# Nodes - RKE Nodes
################################

# Availability Set
resource "azurerm_availability_set" "rke" {
  name                        = "as-rke"
  location                    = azurerm_resource_group.resourcegroup.location
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  platform_fault_domain_count = 2

  # tags = {
  #   environment = "Production"
  # }
}

# Data Disk
resource "azurerm_managed_disk" "rke" {
  count                = var.rke_node_count
  name                 = "disk-rke-data-${count.index}"
  location             = azurerm_resource_group.resourcegroup.location
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

# Network Card
resource "azurerm_network_interface" "rke" {
  count               = var.rke_node_count
  name                = "nic-rke-${count.index}"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  ip_configuration {
    name                          = "ip-configuration-rke-${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "rke" {
  count                     = var.rke_node_count
  network_interface_id      = element(azurerm_network_interface.rke.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.rke.id
}

# Virtual Machine
resource "azurerm_virtual_machine" "rke" {
  count                            = var.rke_node_count
  availability_set_id              = azurerm_availability_set.rke.id
  name                             = "node-rke-${count.index}"
  location                         = azurerm_resource_group.resourcegroup.location
  resource_group_name              = azurerm_resource_group.resourcegroup.name
  network_interface_ids            = [element(azurerm_network_interface.rke.*.id, count.index)]
  vm_size                          = var.rke_node_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.rke_node_image_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "disk-rke-os-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.rke.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.rke.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.rke.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "rke-node-${count.index}"
    admin_username = var.administrator_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.administrator_username}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
      # key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://releases.rancher.com/install-docker/${var.docker_version}.sh | sh && sudo usermod -a -G docker ${var.administrator_username}",
    ]

    connection {
      host        = azurerm_network_interface.rke[count.index].private_ip_address
      type        = "ssh"
      user        = var.administrator_username
      private_key = tls_private_key.ssh.private_key_pem
      # private_key = file("~/.ssh/id_rsa")

      bastion_host        = azurerm_public_ip.frontend.ip_address
      bastion_user        = var.administrator_username
      bastion_private_key = tls_private_key.ssh.private_key_pem
      # bastion_private_key = file("~/.ssh/id_rsa")
    }
  }
  depends_on = [azurerm_virtual_machine.bastion]
}

################################
# Node - Bastion Host
################################

resource "azurerm_availability_set" "bastion" {
  name                        = "as-bastion"
  location                    = azurerm_resource_group.resourcegroup.location
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  platform_fault_domain_count = 2

  # tags = {
  #   environment = "Production"
  # }
}

# Network Interface
resource "azurerm_network_interface" "bastion" {
  name                = "nic-bastion-1"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  ip_configuration {
    name      = "ip-configuration-bastion-1"
    subnet_id = azurerm_subnet.bastion.id
    # public_ip_address_id          = azurerm_public_ip.bastion.id
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
  name                             = "node-bastion-1"
  availability_set_id              = azurerm_availability_set.bastion.id
  location                         = azurerm_resource_group.resourcegroup.location
  resource_group_name              = azurerm_resource_group.resourcegroup.name
  network_interface_ids            = [azurerm_network_interface.bastion.id]
  vm_size                          = var.bastion_node_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "disk-bastion-os-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "bastion-1"
    admin_username = var.administrator_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.administrator_username}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
      # key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  provisioner "file" {
    content = tls_private_key.ssh.private_key_pem
    # source      = "~/.ssh/id_rsa"
    destination = "/home/${var.administrator_username}/.ssh/id_rsa"

    connection {
      host = azurerm_public_ip.frontend.ip_address
      # host        = azurerm_public_ip.bastion.ip_address
      type        = "ssh"
      user        = var.administrator_username
      private_key = tls_private_key.ssh.private_key_pem
      # private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/${var.administrator_username}/.ssh/id_rsa",
    ]

    connection {
      host = azurerm_public_ip.frontend.ip_address
      # host        = azurerm_public_ip.bastion.ip_address
      type        = "ssh"
      user        = var.administrator_username
      private_key = tls_private_key.ssh.private_key_pem
      # private_key = file("~/.ssh/id_rsa")
    }
  }
  depends_on = [azurerm_lb.frontend]
}