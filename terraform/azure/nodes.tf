################################
# Node Configuration
################################

# RSA PKE for authentication
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# resource "local_file" "ssh_private" {
#   sensitive_content  = tls_private_key.ssh.private_key_pem
#   filename           = "${path.root}/ssh_private_key"
#   file_permission    = "0600"
# }

# Diagnostic and config storage account
resource "azurerm_storage_account" "config" {
  name                     = "${substr(replace(local.name_prefix, "-", ""), 0, 22)}sa"
  location                 = azurerm_resource_group.rancher_ha.location
  resource_group_name      = azurerm_resource_group.rancher_ha.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Availability Set
resource "azurerm_availability_set" "rancher_ha" {
  name                        = "${local.name_prefix}-as"
  location                    = azurerm_resource_group.rancher_ha.location
  resource_group_name         = azurerm_resource_group.rancher_ha.name
  platform_fault_domain_count = 2
}

################################
# Data Disks
################################

# Data Disk 1
# resource "azurerm_managed_disk" "etcd1" {
#   count                = var.node_count
#   name                 = "${local.name_prefix}-${count.index}-etcd1-disk"
#   location             = azurerm_resource_group.rancher_ha.location
#   resource_group_name  = azurerm_resource_group.rancher_ha.name
#   storage_account_type = "Premium_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "256"
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "etcd1" {
#   count                = var.node_count
#   virtual_machine_id = element(azurerm_linux_virtual_machine.rancher_ha.*.id, count.index)
#   managed_disk_id    = element(azurerm_managed_disk.etcd1.*.id, count.index)
#   lun                = 0
#   caching            = "None"
# }

# Data Disk 2
# resource "azurerm_managed_disk" "etcd2" {
#   count                = var.node_count
#   name                 = "${local.name_prefix}-${count.index}-etcd2-disk"
#   location             = azurerm_resource_group.rancher_ha.location
#   resource_group_name  = azurerm_resource_group.rancher_ha.name
#   storage_account_type = "Premium_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "256"
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "etcd2" {
#   count                = var.node_count
#   virtual_machine_id = element(azurerm_linux_virtual_machine.rancher_ha.*.id, count.index)
#   managed_disk_id    = element(azurerm_managed_disk.etcd2.*.id, count.index)
#   lun                = 1
#   caching            = "None"
# }

# Data Disk 3
# resource "azurerm_managed_disk" "backup" {
#   count                = var.node_count
#   name                 = "${local.name_prefix}-${count.index}-backup-disk"
#   location             = azurerm_resource_group.rancher_ha.location
#   resource_group_name  = azurerm_resource_group.rancher_ha.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "1024"
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "data" {
#   count                = var.node_count
#   virtual_machine_id = element(azurerm_linux_virtual_machine.rancher_ha.*.id, count.index)
#   managed_disk_id    = element(azurerm_managed_disk.backup.*.id, count.index)
#   lun                = 2
#   caching            = "None"
# }

# Cloud-init
# data "template_file" "cloudconfig" {
#   template = file("${path.module}/cloud-init/cloud-init.tpl")
# }

# data "template_cloudinit_config" "config" {
#   gzip          = true
#   base64_encode = true

#   part {
#     content_type = "text/cloud-config"
#     content      = "${data.template_file.cloudconfig.rendered}"
#   }
# }

# Network Card
resource "azurerm_network_interface" "rancher_ha" {
  count               = var.node_count
  name                = "${local.name_prefix}-${count.index}-nic"
  location            = azurerm_resource_group.rancher_ha.location
  resource_group_name = azurerm_resource_group.rancher_ha.name

  ip_configuration {
    name                          = "ip-configuration-rancher-${count.index}"
    subnet_id                     = data.azurerm_subnet.rancher.id
    private_ip_address_allocation = "dynamic"
  }
  depends_on = [
    azurerm_lb.frontend
  ]
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "rancher_ha" {
  count                     = var.node_count
  network_interface_id      = element(azurerm_network_interface.rancher_ha.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.rancher_ha.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "rancher_ha" {
  count = var.node_count
  name  = "${local.name_prefix}-${count.index}"
  computer_name         = "${replace(local.name_prefix, "-", "")}${count.index}"
  location              = azurerm_resource_group.rancher_ha.location
  resource_group_name   = azurerm_resource_group.rancher_ha.name
  availability_set_id   = azurerm_availability_set.rancher_ha.id
  network_interface_ids = [element(azurerm_network_interface.rancher_ha.*.id, count.index)]
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
    storage_account_uri = azurerm_storage_account.config.primary_blob_endpoint
  }

  source_image_reference {
    publisher = var.node_image_sku.publisher
    offer     = var.node_image_sku.offer
    sku       = var.node_image_sku.sku
    version   = var.node_image_sku.version
  }

  os_disk {
    name                 = "${local.name_prefix}-${count.index}-os-disk"
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
}

# resource "azurerm_virtual_machine_extension" "rancher_ha" {
#   count                = var.node_count
#   name                 = "docker-${var.node_docker_version}"
#   virtual_machine_id   = element(azurerm_linux_virtual_machine.rancher_ha.*.id, count.index)
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   settings = <<SETTINGS
#     {
#         "script": "${base64encode(templatefile("${path.root}/../../../scripts/node-install-docker.sh", {
#           docker_version="${var.node_docker_version}", linux_username="${var.linux_username}"
#         }))}"
#     }
# SETTINGS
#     # {
#     #     "fileUris": [ "https://releases.rancher.com/install-docker/${var.node_docker_version}.sh" ],
#     #     "commandToExecute": "bash ${var.node_docker_version}.sh && sudo usermod -a -G docker ${var.linux_username}"
#     # }
# }
