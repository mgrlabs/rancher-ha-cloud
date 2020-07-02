resource "rancher2_node_template" "azure" {
  name = "Azure Small Node"
  description = "Azure small node template"
  cloud_credential_id = rancher2_cloud_credential.azure.id
  azure_config {
    location = var.azure_location
    availability_set = "rancher2-rke-as"
    update_domain_count = "2"
    resource_group = var.azure_rg
    managed_disks = false
    vnet = var.azure_vnet && var.azure_rg
    subnet_prefix = var.azure_subnet_prefix
    subnet = "cluster-subnet"
    size = var.azure_vm_size
    open_port = [
      "6443/tcp",
      "2379/tcp",
      "2380/tcp",
      "8472/udp",
      "4789/udp",
      "9796/tcp",
      "10256/tcp",
      "10250/tcp","10251/tcp","10252/tcp",]
    static_public_ip = true
    no_public_ip = true
    use_private_ip = true
  }
}

// resource "azurerm_availability_set" "rancher_ha" {
//   name                        = "${local.name_prefix}-as"
//   location                    = azurerm_resource_group.rancher_ha.location
//   resource_group_name         = azurerm_resource_group.rancher_ha.name
//   platform_fault_domain_count = 2
// }