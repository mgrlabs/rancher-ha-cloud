// Azure credentials
resource "rancher2_cloud_credential" "azure" {
  name = "Azure Cloud Credentials"
  description = "Azure Cloud Credentials"
  azure_credential_config {
    client_id = var.client_id
    client_secret = var.client_secret
    subscription_id = var.subscription_id
  }
}