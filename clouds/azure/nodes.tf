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

resource "azurerm_storage_account" "config" {
  name                     = "${var.environment}${var.company_prefix}ranchersa"
  location                 = azurerm_resource_group.rancher_ha.location
  resource_group_name      = azurerm_resource_group.rancher_ha.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

################################
# Nodes - Rancher
################################

# Availability Set
resource "azurerm_availability_set" "rancher_ha" {
  name                        = "${var.environment}-rancher-nodes-as"
  location                    = azurerm_resource_group.rancher_ha.location
  resource_group_name         = azurerm_resource_group.rancher_ha.name
  platform_fault_domain_count = 2
}

# Data Disk 1
resource "azurerm_managed_disk" "etcd1" {
  count                = var.rancher_node_count
  name                 = "${var.environment}-rancher-node-${count.index}-etcd1-disk"
  location             = azurerm_resource_group.rancher_ha.location
  resource_group_name  = azurerm_resource_group.rancher_ha.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
}

# Data Disk 2
resource "azurerm_managed_disk" "etcd2" {
  count                = var.rancher_node_count
  name                 = "${var.environment}-rancher-node-${count.index}-etcd2-disk"
  location             = azurerm_resource_group.rancher_ha.location
  resource_group_name  = azurerm_resource_group.rancher_ha.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
}

# Data Disk 3
resource "azurerm_managed_disk" "backup" {
  count                = var.rancher_node_count
  name                 = "${var.environment}-rancher-node-${count.index}-backup-disk"
  location             = azurerm_resource_group.rancher_ha.location
  resource_group_name  = azurerm_resource_group.rancher_ha.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "512"
}

# Cloud-init
data "template_file" "cloudconfig" {
  template = file("${path.module}/cloud-init/cloud-init.tpl")
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}

# Network Card
resource "azurerm_network_interface" "rancher_ha" {
  count               = var.rancher_node_count
  name                = "${var.environment}-rancher-node-${count.index}-nic"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name

  ip_configuration {
    name                          = "ip-configuration-rancher-${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "rancher_ha" {
  count                     = var.rancher_node_count
  network_interface_id      = element(azurerm_network_interface.rancher_ha.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.rancher_ha.id
}

# Virtual Machine
resource "azurerm_virtual_machine" "rancher_ha" {
  count                            = var.rancher_node_count
  availability_set_id              = azurerm_availability_set.rancher_ha.id
  name                             = "${var.environment}-rancher-node-${count.index}"
  location                         = azurerm_resource_group.rancher_ha.location
  resource_group_name              = azurerm_resource_group.rancher_ha.name
  network_interface_ids            = [element(azurerm_network_interface.rancher_ha.*.id, count.index)]
  vm_size                          = var.rancher_node_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.config.primary_blob_endpoint
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.rancher_ubuntu_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.environment}-rancher-node-${count.index}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.etcd1.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.etcd1.*.id, count.index)
    disk_size_gb    = element(azurerm_managed_disk.etcd1.*.disk_size_gb, count.index)
    create_option   = "Attach"
    lun             = 0
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.etcd2.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.etcd2.*.id, count.index)
    disk_size_gb    = element(azurerm_managed_disk.etcd2.*.disk_size_gb, count.index)
    create_option   = "Attach"
    lun             = 1
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.backup.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.backup.*.id, count.index)
    disk_size_gb    = element(azurerm_managed_disk.backup.*.disk_size_gb, count.index)
    create_option   = "Attach"
    lun             = 2
  }

  os_profile {
    computer_name  = "${var.environment}-rancher-node-${count.index}"
    admin_username = var.linux_username
    custom_data    = data.template_cloudinit_config.config.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.linux_username}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://releases.rancher.com/install-docker/${var.rancher_docker_version}.sh | sh && sudo usermod -a -G docker ${var.linux_username}",
    ]

    connection {
      host        = azurerm_network_interface.rancher_ha[count.index].private_ip_address
      type        = "ssh"
      user        = var.linux_username
      private_key = tls_private_key.ssh.private_key_pem

      bastion_host        = azurerm_public_ip.frontend.ip_address
      bastion_user        = var.linux_username
      bastion_private_key = tls_private_key.ssh.private_key_pem
    }
  }
  depends_on = [azurerm_virtual_machine.bastion]
}

################################
# Node - Bastion
################################

resource "azurerm_availability_set" "bastion" {
  name                        = "${var.environment}-rancher-bastion-as"
  location                    = azurerm_resource_group.rancher_ha.location
  resource_group_name         = azurerm_resource_group.rancher_ha.name
  platform_fault_domain_count = 2
}

# Network Interface
resource "azurerm_network_interface" "bastion" {
  name                = "${var.environment}-rancher-bastion-nic"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name

  ip_configuration {
    name                          = "ip-configuration-bastion"
    subnet_id                     = azurerm_subnet.bastion.id
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
  name                             = "${var.environment}-rancher-bastion"
  availability_set_id              = azurerm_availability_set.bastion.id
  location                         = azurerm_resource_group.rancher_ha.location
  resource_group_name              = azurerm_resource_group.rancher_ha.name
  network_interface_ids            = [azurerm_network_interface.bastion.id]
  vm_size                          = var.bastion_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.config.primary_blob_endpoint
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.environment}-rancher-bastion-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.environment}-bastion"
    admin_username = var.linux_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.linux_username}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  provisioner "file" {
    content     = tls_private_key.ssh.private_key_pem
    destination = "/home/${var.linux_username}/.ssh/id_rsa"

    connection {
      host        = azurerm_public_ip.frontend.ip_address
      type        = "ssh"
      user        = var.linux_username
      private_key = tls_private_key.ssh.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/${var.linux_username}/.ssh/id_rsa",
    ]

    connection {
      host        = azurerm_public_ip.frontend.ip_address
      type        = "ssh"
      user        = var.linux_username
      private_key = tls_private_key.ssh.private_key_pem
    }
  }
  depends_on = [azurerm_lb.frontend]
}
