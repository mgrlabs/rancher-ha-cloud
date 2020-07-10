################################
# Cluster Secrets
################################

resource "azurerm_storage_container" "rancher" {
  name                  = "rancher"
  storage_account_name  = azurerm_storage_account.rancher.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ssh_private_key" {
  name                   = "${replace(local.name_prefix, "-", "")}-private_key_pem"
  storage_account_name   = azurerm_storage_account.rancher.name
  storage_container_name = azurerm_storage_container.rancher.name
  type                   = "Block"
  source_content         = tls_private_key.ssh.private_key_pem
}

resource "azurerm_storage_blob" "rke_cluster_config" {
  name                   = "${replace(local.name_prefix, "-", "")}-rke_cluster_config"
  storage_account_name   = azurerm_storage_account.rancher.name
  storage_container_name = azurerm_storage_container.rancher.name
  type                   = "Block"
  source_content         = module.rancher_common.rke_cluster_config
}

resource "azurerm_storage_blob" "rancher_admin_password" {
  name                   = "${replace(local.name_prefix, "-", "")}-rancher_password"
  storage_account_name   = azurerm_storage_account.rancher.name
  storage_container_name = azurerm_storage_container.rancher.name
  type                   = "Block"
  source_content         = module.rancher_common.rancher_admin_password
}

resource "azurerm_key_vault_secret" "rancher_api_token" {
  name         = "rancherApiToken"
  value        = module.rancher_common.rancher_admin_api_token
  key_vault_id = azurerm_key_vault.rancher.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_admin_password" {
  name         = "rancherAdminPassword"
  value        = module.rancher_common.rancher_admin_password
  key_vault_id = azurerm_key_vault.rancher.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_kubeapi_context" {
  name         = "rancherKubeApiContext"
  value        = module.rancher_common.rke_cluster_config
  key_vault_id = azurerm_key_vault.rancher.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_node_private_key_pem" {
  name         = "rancherNodePrivateKeyPem"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.rancher.id

  tags = local.tags
}