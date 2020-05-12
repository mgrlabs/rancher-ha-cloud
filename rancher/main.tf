# REQUIRES: ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_vX.X.X
provider "rke" {
  version = "v1.0.0-rc5"
}

################################
# Azure RM Provider
################################

provider "azurerm" {
  version = "=2.8.0"
  features {}
}

data "azurerm_client_config" "current" {
}

################################
# RKE Cluster Deploy
################################

resource "rke_cluster" "cluster" {
  dynamic "nodes" {
    iterator = node
    for_each = module.azure_cluster.k8s_nodes_names
    content {
      address           = module.azure_cluster.k8s_nodes_private_ips[node.key]
      hostname_override = module.azure_cluster.k8s_nodes_names[node.key]
      user              = module.azure_cluster.admin_name
      role              = ["controlplane", "worker", "etcd"]
      ssh_key           = module.azure_cluster.tls_private_key
    }
  }

  cluster_name = module.azure_cluster.domain_name_prefix

  bastion_host {
    address = module.azure_cluster.bastion_node_public_ip
    user    = module.azure_cluster.admin_name
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
    provider = "nginx"
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
    module.azure_cluster.k8s_nodes_names
  ]
}

################################
# Cluster Config
################################

# Required for kubectl
resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = replace(rke_cluster.cluster.kube_config_yaml, "/server:.*/", "server: \"https://${module.azure_cluster.lb_rancher_fqdn}:6443\"")
}

################################
# Kubernetes - Namespaces
################################

provider "kubernetes" {
  load_config_file       = "false"
  host                   = "https://${module.azure_cluster.lb_rancher_fqdn}:6443"
  username               = rke_cluster.cluster.kube_admin_user
  client_certificate     = rke_cluster.cluster.client_cert
  client_key             = rke_cluster.cluster.client_key
  cluster_ca_certificate = rke_cluster.cluster.ca_crt
}

resource "kubernetes_namespace" "cattle_system" {
  metadata {
    name = "cattle-system"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

################################
# Helm Deployments
################################

provider "helm" {
  kubernetes {
    host                   = "https://${module.azure_cluster.lb_rancher_fqdn}:6443"
    username               = rke_cluster.cluster.kube_admin_user
    client_certificate     = rke_cluster.cluster.client_cert
    client_key             = rke_cluster.cluster.client_key
    cluster_ca_certificate = rke_cluster.cluster.ca_crt
  }
}

# Helm - Deploy Cert-Manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "cert-manager"
  chart      = "cert-manager"
  version    = "v0.15.0"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    rke_cluster.cluster,
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
    value = var.k8s_node_count
  }
  depends_on = [
    helm_release.cert_manager,
    kubernetes_namespace.cattle_system
  ]
}
