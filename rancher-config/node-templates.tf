################################
# Node Templates
################################

resource "rancher2_node_template" "rancher" {
  count               = length(local.azure_node_templates)
  name                = local.azure_node_templates[count.index].template_name
  description         = "Node template (${local.azure_node_templates[count.index].template_name_short}) for the ${var.cloud} ${var.environment} environment."
  cloud_credential_id = rancher2_cloud_credential.rancher.id

  azure_config {
    image = var.node_image_urn
    size  = local.azure_node_templates[count.index].node_size

    location            = local.azure_node_templates[count.index].region
    resource_group      = "${local.azure_node_templates[count.index].node_prefix}-rg"
    availability_set    = "${local.azure_node_templates[count.index].node_prefix}-as"
    update_domain_count = local.azure_node_templates[count.index].fault_update_domains
    fault_domain_count  = local.azure_node_templates[count.index].fault_update_domains

    managed_disks = true
    storage_type  = local.azure_node_templates[count.index].node_storage_type
    disk_size     = local.azure_node_templates[count.index].node_disk_size

    vnet             = "${local.azure_node_templates[count.index].vnet_prefix}-rg:${local.azure_node_templates[count.index].vnet_prefix}-vnet"
    subnet_prefix    = local.azure_node_templates[count.index].subnet_prefix
    subnet           = local.azure_node_templates[count.index].subnet_name
    static_public_ip = true
    no_public_ip     = true
    use_private_ip   = true

    open_port = var.open_ports
    ssh_user  = "rancheradmin"
  }
}