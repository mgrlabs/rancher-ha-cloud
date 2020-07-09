################################
# Cloud Credentials
################################

resource "rancher2_cloud_credential" "rancher" {
  name        = "cloudcred-${var.environment}-${var.cloud}"
  description = "Cloud credentials for the ${var.cloud} ${var.environment} environment."

  dynamic "azure_credential_config" {
    for_each = var.cloud == "azure" ? [var.cloud] : []
    content {
      client_id       = var.azure_service_principal_client_id
      client_secret   = var.azure_service_principal_client_secret
      subscription_id = var.azure_subscription_id
    }
  }

  dynamic "amazonec2_credential_config" {
    for_each = var.cloud == "aws" ? [var.cloud] : []
    content {
      access_key = var.aws_access_key
      secret_key = var.aws_secret_key
    }
  }
}