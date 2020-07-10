################################
# Node Configuration
################################

# RSA PKE for authentication
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Diagnostic and config storage account
resource "azurerm_storage_account" "rancher" {
  name                     = "${substr(replace(local.name_prefix, "-", ""), 0, 22)}sa"
  location                 = azurerm_resource_group.rancher.location
  resource_group_name      = azurerm_resource_group.rancher.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

# Availability set
resource "azurerm_availability_set" "rancher" {
  name                        = "${local.name_prefix}-as"
  location                    = azurerm_resource_group.rancher.location
  resource_group_name         = azurerm_resource_group.rancher.name
  platform_fault_domain_count = 2

  tags = local.tags
}

# Network card
resource "azurerm_network_interface" "rancher" {
  count               = var.node_count
  name                = "${local.name_prefix}-node-${count.index}-nic"
  location            = azurerm_resource_group.rancher.location
  resource_group_name = azurerm_resource_group.rancher.name

  ip_configuration {
    name                          = "ip-configuration-rancher-${count.index}"
    subnet_id                     = data.azurerm_subnet.rancher.id
    private_ip_address_allocation = "dynamic"
  }

  tags = local.tags

  depends_on = [
    azurerm_lb.rancher
  ]
}

# NSG association
resource "azurerm_network_interface_security_group_association" "rancher" {
  count                     = var.node_count
  network_interface_id      = element(azurerm_network_interface.rancher.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.rancher.id
}

# Virtual machines
resource "azurerm_linux_virtual_machine" "rancher" {
  count                 = var.node_count
  name                  = "${local.name_prefix}-node-${count.index}"
  computer_name         = "${replace(local.name_prefix, "-", "")}${count.index}"
  location              = azurerm_resource_group.rancher.location
  resource_group_name   = azurerm_resource_group.rancher.name
  availability_set_id   = azurerm_availability_set.rancher.id
  network_interface_ids = [element(azurerm_network_interface.rancher.*.id, count.index)]
  size                  = var.node_vm_size

  custom_data = base64encode(
    templatefile(
      join("/", [path.module, "../cloud-common/cloud_init.tpl"]),
      {
        docker_version = var.node_docker_version
        username       = var.linux_username
      }
    )
  )

  admin_username                  = var.linux_username
  disable_password_authentication = true

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.rancher.primary_blob_endpoint
  }

  source_image_reference {
    publisher = var.node_image_sku.publisher
    offer     = var.node_image_sku.offer
    sku       = var.node_image_sku.sku
    version   = var.node_image_sku.version
  }

  os_disk {
    name                 = "${local.name_prefix}-node-${count.index}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = "30"
  }

  admin_ssh_key {
    username   = var.linux_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Cloud-init: Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Cloud-init: Completed!'",
    ]

    connection {
      type        = "ssh"
      host        = self.private_ip_address
      user        = var.linux_username
      private_key = tls_private_key.ssh.private_key_pem
    }
  }

  provisioner "file" {
    source      = "${path.module}/cloud-config/node-data-drives.sh"
    destination = "/tmp/node-data-drives.sh"

    connection {
      type        = "ssh"
      host        = self.private_ip_address
      user        = var.linux_username
      private_key = tls_private_key.ssh.private_key_pem
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/node-data-drives.sh"
    ]
    connection {
      type        = "ssh"
      host        = self.private_ip_address
      user        = var.linux_username
      private_key = tls_private_key.ssh.private_key_pem
    }
  }

  tags = local.tags
}

# Data Disk 1
resource "azurerm_managed_disk" "etcd0" {
  count                = var.node_count
  name                 = "${local.name_prefix}-node-${count.index}-etcd0-disk"
  location             = azurerm_resource_group.rancher.location
  resource_group_name  = azurerm_resource_group.rancher.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "etcd0" {
  count              = var.node_count
  virtual_machine_id = element(azurerm_linux_virtual_machine.rancher.*.id, count.index)
  managed_disk_id    = element(azurerm_managed_disk.etcd0.*.id, count.index)
  lun                = 0
  caching            = "None"
}

# Data Disk 2
resource "azurerm_managed_disk" "etcd1" {
  count                = var.node_count
  name                 = "${local.name_prefix}-node-${count.index}-etcd1-disk"
  location             = azurerm_resource_group.rancher.location
  resource_group_name  = azurerm_resource_group.rancher.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "etcd1" {
  count              = var.node_count
  virtual_machine_id = element(azurerm_linux_virtual_machine.rancher.*.id, count.index)
  managed_disk_id    = element(azurerm_managed_disk.etcd1.*.id, count.index)
  lun                = 1
  caching            = "None"
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.etcd0
  ]
}

# Data Disk 3
resource "azurerm_managed_disk" "backup" {
  count                = var.node_count
  name                 = "${local.name_prefix}-node-${count.index}-backup-disk"
  location             = azurerm_resource_group.rancher.location
  resource_group_name  = azurerm_resource_group.rancher.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1024"

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "backup" {
  count              = var.node_count
  virtual_machine_id = element(azurerm_linux_virtual_machine.rancher.*.id, count.index)
  managed_disk_id    = element(azurerm_managed_disk.backup.*.id, count.index)
  lun                = 2
  caching            = "None"
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.etcd1
  ]
}

resource "azurerm_virtual_machine_extension" "rancher" {
  count                = var.node_count
  name                 = "Data-Drive-Mount"
  virtual_machine_id   = element(azurerm_linux_virtual_machine.rancher.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo /tmp/node-data-drives.sh"
    }
SETTINGS

  tags = local.tags

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.backup
  ]
}
