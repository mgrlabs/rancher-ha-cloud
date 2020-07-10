################################
# RKE Cluster Deploy
################################

resource "rke_cluster" "rancher" {
  dynamic "nodes" {
    iterator = node
    for_each = var.node_azure_names
    content {
      address           = var.node_ip_addresses[node.key]
      hostname_override = var.node_azure_names[node.key]
      user              = var.linux_username
      role              = ["controlplane", "worker", "etcd"]
      ssh_key           = var.node_ssh_private_key
    }
  }

  services {
    etcd {
      # Etcd snapshots
      # https://rancher.com/docs/rancher/v2.x/en/backups/backups/ha-backups/

      backup_config {
        enabled        = true # enables recurring etcd snapshots
        interval_hours = 6    # time increment between snapshots
        retention      = 90   # time in days before snapshot purge
      }

      # Performance tuning etcd
      # https://rancher.com/docs/rancher/v2.x/en/installation/options/etcd/

      extra_args = {
        data-dir = "/var/lib/rancher/etcd/data/"
        wal-dir  = "/var/lib/rancher/etcd/wal/wal_dir"

        # https://etcd.io/docs/v3.4.0/tuning/

        quota-backend-bytes = 6442450944 # 6GB
        election-timeout    = 50000
        heartbeat-interval  = 10000
      }

      extra_binds = [
        "/var/lib/etcd/data:/var/lib/rancher/etcd/data", # Managed disk etcd1
        "/var/lib/etcd/wal:/var/lib/rancher/etcd/wal",   # Managed disk etcd2
      ]
    }
  }

  cluster_name = var.load_balancer_fqdn

  authentication {
    strategy = "x509"
    sans = [
      var.load_balancer_fqdn,
      var.load_balancer_private_ip,
    ]
  }

  network {
    plugin = "canal"
  }

  ingress {
    provider = "nginx"
  }

  cloud_provider {
    name = "azure"
    azure_cloud_provider {
      tenant_id         = var.azure_tenant_id
      subscription_id   = var.azure_subscription_id
      aad_client_id     = var.azure_service_principal_client_id
      aad_client_secret = var.azure_service_principal_client_secret
      # cloud_provider_backoff =  true
      # cloud_provider_backoff_retries = "3"
      # cloud_provider_backoff_exponent = "3"
      # cloud_provider_backoff_duration = "3"
      # cloud_provider_backoff_jitter = "3"
      # cloud_provider_rate_limit = false
      # cloud_provider_rate_limit_qps = "0"
      # cloud_provider_rate_limit_bucket = "0"
    }
  }
  depends_on = [
    var.rke_depends_on
  ]
}
