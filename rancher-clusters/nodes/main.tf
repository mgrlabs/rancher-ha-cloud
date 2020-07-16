data "rancher2_cloud_credential" "nodes" {
  name = "cloudcred-${var.environment}-${var.cloud}"
}

data "azurerm_subnet" "nodes" {
  name                 = var.node_vnet_subnet_name
  virtual_network_name = "${var.environment}-${var.region}-rancher-vnet"
  resource_group_name  = "${var.environment}-${var.region}-rancher-vnet-rg"
}

resource "rancher2_node_template" "nodes" {
  name                = local.rancher_prefix
  description         = "Node template for the ${var.node_role_suffix} nodes in the ${var.cloud} ${var.environment} environment."
  cloud_credential_id = data.rancher2_cloud_credential.nodes.id

  azure_config {
    image = var.node_image_urn
    size  = var.node_vm_size

    location            = var.region
    environment         = "AzurePublicCloud"
    resource_group      = var.node_azure_resource_group
    availability_set    = "${local.node_prefix}-as"
    update_domain_count = var.region_fault_update_domains
    fault_domain_count  = var.region_fault_update_domains

    managed_disks = true
    storage_type  = var.node_disk_type
    disk_size     = var.node_disk_size

    vnet             = "${var.environment}-${var.region}-rancher-vnet-rg:${var.environment}-${var.region}-rancher-vnet"
    subnet_prefix    = data.azurerm_subnet.nodes.address_prefixes[0]
    subnet           = var.node_vnet_subnet_name
    static_public_ip = true
    no_public_ip     = true
    use_private_ip   = true

    open_port   = var.open_ports
    ssh_user    = "rancheradmin"
    docker_port = "2376"
  }
}

resource "rancher2_node_pool" "module" {
  cluster_id       = var.rancher_cluster_id
  name             = local.rancher_prefix
  hostname_prefix  = local.node_prefix
  node_template_id = rancher2_node_template.nodes.id
  quantity         = var.node_quantity
  etcd             = var.etcd_enable
  control_plane    = var.control_plane_enable
  worker           = var.worker_enable
}