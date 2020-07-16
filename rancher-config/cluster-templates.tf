################################
# RKE Template - Baseline
################################

resource "rancher2_cluster_template" "baseline" {
  name        = "baseline-${var.environment}-${var.cloud}"
  description = "Terraform deployed RKE template for the ${var.product} ${var.environment} environment in ${var.cloud}"
  #members {  }

  template_revisions {
    name    = "v1"
    default = true
    enabled = true
    #labels = {    }
    cluster_config {
      rke_config {
        cloud_provider {
          name = "azure"
          azure_cloud_provider {
            tenant_id         = var.azure_tenant_id
            subscription_id   = var.azure_subscription_id
            aad_client_id     = var.azure_service_principal_client_id
            aad_client_secret = var.azure_service_principal_client_secret
          }
        }
        network {
          plugin = "canal"
        }
        services {
          etcd {
            creation  = "6h"
            retention = "24h"
          }
        }
      }
    }
  }
}
