################################
# Cluster Secrets
################################

resource "azurerm_storage_container" "rancher" {
  name                  = "rancher"
  storage_account_name  = azurerm_storage_account.config.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ssh_private_key" {
  name                   = "${replace(local.name_prefix, "-", "")}-private_key_pem"
  storage_account_name   = azurerm_storage_account.config.name
  storage_container_name = azurerm_storage_container.rancher.name
  type                   = "Block"
  source_content         = tls_private_key.ssh.private_key_pem
}

resource "azurerm_storage_blob" "rke_cluster_config" {
  name                   = "${replace(local.name_prefix, "-", "")}-rke_cluster_config"
  storage_account_name   = azurerm_storage_account.config.name
  storage_container_name = azurerm_storage_container.rancher.name
  type                   = "Block"
  source_content         = module.rancher_common.rke_cluster_config
}

resource "azurerm_storage_blob" "rancher_admin_password" {
  name                   = "${replace(local.name_prefix, "-", "")}-rancher_password"
  storage_account_name   = azurerm_storage_account.config.name
  storage_container_name = azurerm_storage_container.rancher.name
  type                   = "Block"
  source_content         = module.rancher_common.rancher_admin_password
}