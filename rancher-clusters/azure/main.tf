################################
# Resource Group
################################

resource "azurerm_resource_group" "rancher_cluster" {
  name     = "${local.azure_prefix}-rg"
  location = var.region

  tags = local.tags
}

data "azurerm_client_config" "current" {
}

# data "azurerm_subnet" "azure" {
#   name                 = var.node_config_etcd.subnet_name
#   virtual_network_name = "${local.vnet_prefix}"
#   resource_group_name  = "${local.vnet_prefix}-rg"
# }

################################
# Rancher Cluster
################################

data "rancher2_cluster_template" "rancher_cluster" {
  name = "baseline-${var.environment}-${var.cloud}"
}

resource "rancher2_cluster" "rancher_cluster" {
  name                         = "${local.rancher_prefix}-rke"
  cluster_template_id          = data.rancher2_cluster_template.rancher_cluster.id
  cluster_template_revision_id = data.rancher2_cluster_template.rancher_cluster.template_revisions.0.id

  annotations = {
    "resource.group"     = azurerm_resource_group.rancher_cluster.name
    "created.time"       = timestamp()
    "created.owner.guid" = data.azurerm_client_config.current.client_id
  }
}

################################
# Nodes
################################

# Nodes - Worker
module nodes_worker {
  source                      = "../nodes"
  node_role_suffix            = "worker"
  product                     = var.product
  cloud                       = var.cloud
  environment                 = var.environment
  region                      = var.region
  node_azure_resource_group   = "${local.azure_prefix}-rg"
  region_fault_update_domains = var.node_config_worker.fault_update_domains
  node_subnet_name            = var.node_config_worker.subnet_name

  # node config
  node_vm_size   = var.node_config_worker.vm_size
  node_disk_type = var.node_config_worker.disk_type
  node_disk_size = var.node_config_worker.disk_size

  # node pool
  node_quantity      = var.node_config_worker.quantity
  rancher_cluster_id = rancher2_cluster.rancher_cluster.id
  worker_enable      = true
}

# Nodes - Etcd
module nodes_etcd {
  source                      = "../nodes"
  node_role_suffix            = "etcd"
  product                     = var.product
  cloud                       = var.cloud
  environment                 = var.environment
  region                      = var.region
  node_azure_resource_group   = "${local.azure_prefix}-rg"
  region_fault_update_domains = var.node_config_worker.fault_update_domains
  node_subnet_name            = var.node_config_worker.subnet_name

  # node config
  node_vm_size   = var.node_config_etcd.vm_size
  node_disk_type = var.node_config_etcd.disk_type
  node_disk_size = var.node_config_etcd.disk_size

  # node pool
  node_quantity      = var.node_config_etcd.quantity
  rancher_cluster_id = rancher2_cluster.rancher_cluster.id
  etcd_enable        = true
}

# Nodes - Control
module nodes_control {
  source                      = "../nodes"
  node_role_suffix            = "control"
  product                     = var.product
  cloud                       = var.cloud
  environment                 = var.environment
  region                      = var.region
  node_azure_resource_group   = "${local.azure_prefix}-rg"
  region_fault_update_domains = var.node_config_worker.fault_update_domains
  node_subnet_name            = var.node_config_worker.subnet_name

  # node config
  node_vm_size   = var.node_config_control.vm_size
  node_disk_type = var.node_config_control.disk_type
  node_disk_size = var.node_config_control.disk_size

  # node pool
  node_quantity        = var.node_config_control.quantity
  rancher_cluster_id   = rancher2_cluster.rancher_cluster.id
  control_plane_enable = true
}
