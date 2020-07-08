################################
# Azure Deployment
################################

provider "azurerm" {
  version = "=2.14.0"
  features {}
}

data "azurerm_client_config" "current" {
}

module azure_cluster {
  source             = "../clouds/azure"
  arm_location       = var.arm_location
  environment        = var.environment
  rancher_node_count = var.rancher_node_count
  company_prefix     = var.company_prefix
}



################################
# RKE Cluster Deploy
################################

# REQUIRES: ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_vX.X.X
provider "rke" {
  version = "=1.0.0"
}

resource "rke_cluster" "rancher_ha" {
  dynamic "nodes" {
    iterator = node
    for_each = module.azure_cluster.rancher_nodes_names
    content {
      address           = module.azure_cluster.rancher_nodes_private_ips[node.key]
      hostname_override = module.azure_cluster.rancher_nodes_names[node.key]
      user              = module.azure_cluster.linux_username
      role              = ["controlplane", "worker", "etcd"]
      ssh_key           = module.azure_cluster.tls_private_key
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
        data-dir            = "/var/lib/rancher/etcd/data/"
        wal-dir             = "/var/lib/rancher/etcd/wal/wal_dir"
        quota-backend-bytes = 6442450944 # 6GB
        election-timeout    = 5000
        heartbeat-interval  = 500
      }

      extra_binds = [
        "/var/lib/etcd/data:/var/lib/rancher/etcd/data", # Managed disk etcd1
        "/var/lib/etcd/wal:/var/lib/rancher/etcd/wal",   # Managed disk etcd2
      ]
    }
  }

  cluster_name = module.azure_cluster.domain_name_prefix

  bastion_host {
    address = module.azure_cluster.bastion_node_public_ip
    user    = module.azure_cluster.linux_username
    ssh_key = module.azure_cluster.tls_private_key
    port    = 22
  }

  authentication {
    strategy = "x509"
    sans = [
      module.azure_cluster.lb_rancher_fqdn,
    ]
  }

  network {
    plugin = "canal"
  }

  ingress {
    provider  = "nginx"
    options = { 
      use-forwarded-headers = "true"
    }
  }

  cloud_provider {
    name = "azure"
    azure_cloud_provider {
      tenant_id         = data.azurerm_client_config.current.tenant_id
      subscription_id   = data.azurerm_client_config.current.subscription_id
      aad_client_id     = data.azurerm_client_config.current.client_id
      aad_client_secret = var.arm_client_secret
    }
  }
  depends_on = [
    module.azure_cluster.rancher_nodes_names
  ]
}

################################
# Cluster Config
################################

# Required for kubectl & helm
resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = replace(rke_cluster.rancher_ha.kube_config_yaml, "/server:.*/", "server: \"https://${module.azure_cluster.lb_rancher_fqdn}:6443\"")
}

################################
# Kubernetes - Namespaces
################################

provider "kubernetes" {
  load_config_file       = "false"
  host                   = "https://${module.azure_cluster.lb_rancher_fqdn}:6443"
  username               = rke_cluster.rancher_ha.kube_admin_user
  client_certificate     = rke_cluster.rancher_ha.client_cert
  client_key             = rke_cluster.rancher_ha.client_key
  cluster_ca_certificate = rke_cluster.rancher_ha.ca_crt
}

resource "kubernetes_namespace" "cattle_system" {
  metadata {
    name = "cattle-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

################################
# Helm Deployments
################################

provider "helm" {
  kubernetes {
    load_config_file       = "false"
    host                   = "https://${module.azure_cluster.lb_rancher_fqdn}:6443"
    username               = rke_cluster.rancher_ha.kube_admin_user
    client_certificate     = rke_cluster.rancher_ha.client_cert
    client_key             = rke_cluster.rancher_ha.client_key
    cluster_ca_certificate = rke_cluster.rancher_ha.ca_crt
  }
}

# Helm - Deploy Cert-Manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "cert-manager"
  chart      = "cert-manager"
  # version    = "v0.15.0"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    rke_cluster.rancher_ha,
    kubernetes_namespace.cert_manager
  ]
}

# Helm - Deploy Rancher
resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  namespace  = "cattle-system"
  chart      = "rancher"
  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }
  set {
    name  = "hostname"
    value = module.azure_cluster.lb_rancher_fqdn
  }
  set {
    name  = "auditLog.level"
    value = "1"
  }
  set {
    name  = "addLocal"
    value = "true"
  }
  set {
    name  = "replicas"
    value = var.rancher_node_count
  }
  depends_on = [
    helm_release.cert_manager,
    kubernetes_namespace.cattle_system
  ]
}
