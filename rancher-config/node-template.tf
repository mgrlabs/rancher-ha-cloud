################################
# Node Templates
################################

resource "rancher2_node_template" "rancher" {
  for_each            = { for t in local.azure_node_templates : "${t.region}-${t.template_name_short}" => t }
  name                = each.value.template_name
  description         = "Node template (${each.value.template_name_short}) for the ${var.cloud} ${var.environment} environment."
  cloud_credential_id = rancher2_cloud_credential.rancher.id

  azure_config {
    image = var.node_image_urn
    size  = each.value.node_size

    location            = each.value.region
    environment         = "AzurePublicCloud"
    resource_group      = "${each.value.node_prefix}-rg"
    availability_set    = "${each.value.node_prefix}-as"
    update_domain_count = each.value.fault_update_domains
    fault_domain_count  = each.value.fault_update_domains

    managed_disks = true
    storage_type  = each.value.node_storage_type
    disk_size     = each.value.node_disk_size

    vnet             = "${each.value.vnet_prefix}-rg:${each.value.vnet_prefix}-vnet"
    subnet_prefix    = each.value.subnet_prefix
    subnet           = each.value.subnet_name
    static_public_ip = true
    no_public_ip     = true
    use_private_ip   = true

    open_port   = var.open_ports
    ssh_user    = "rancheradmin"
    docker_port = "2376"
  }
}