# REQUIRES: ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_vX.X.X
provider "rke" {
  version = "v1.0.0-rc5"
}

data "azurerm_client_config" "current" {
}

################################
# RKE Cluster Deploy
################################

resource "rke_cluster" "cluster" {
  dynamic "nodes" {
    iterator = node
    for_each = azurerm_virtual_machine.rke
    content {
      address           = azurerm_network_interface.rke[node.key].private_ip_address
      hostname_override = azurerm_virtual_machine.rke[node.key].name
      user              = var.admin_name
      role              = ["controlplane", "worker", "etcd"]
      ssh_key           = tls_private_key.ssh.private_key_pem
    }
  }

  cluster_name = "${var.company_prefix}rancher${var.environment}"

  bastion_host {
    address = azurerm_public_ip.frontend.ip_address
    user    = var.admin_name
    ssh_key = tls_private_key.ssh.private_key_pem
    port    = 22
  }

  authentication {
    strategy = "x509"
    sans = [
      azurerm_public_ip.frontend.fqdn,
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
    azurerm_virtual_machine.rke
  ]
}

################################
# Cluster Config
################################

# Required for kubectl
resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = replace(rke_cluster.cluster.kube_config_yaml, "/server:.*/", "server: \"https://${azurerm_public_ip.frontend.fqdn}:6443\"")
}

################################
# Cert-Manager CRDs
################################

# TO DO: Maybe implement this - https://github.com/banzaicloud/terraform-provider-k8s, kubernetes provider doesn't support static definitions
# resource "null_resource" "cert_manager_crds" {
#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig=${path.root}/kube_config_cluster.yml apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager.crds.yaml"
#   }

#   depends_on = [
#     rke_cluster.cluster,
#     local_file.kube_cluster_yaml
#   ]
# }

################################
# Kubernetes - Namespaces
################################

provider "kubernetes" {
  load_config_file       = "false"
  host                   = "https://${azurerm_public_ip.frontend.fqdn}:6443"
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
    host                   = "https://${azurerm_public_ip.frontend.fqdn}:6443"
    username               = rke_cluster.cluster.kube_admin_user
    client_certificate     = rke_cluster.cluster.client_cert
    client_key             = rke_cluster.cluster.client_key
    cluster_ca_certificate = rke_cluster.cluster.ca_crt
  }
}

data "helm_repository" "cert_manager" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

data "helm_repository" "rancher_latest" {
  name = "rancher-latest"
  url  = "https://releases.rancher.com/server-charts/latest"
}

################################
# Helm - Deploy Cert-Manager
################################

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = data.helm_repository.cert_manager.metadata[0].name
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

################################
# Helm - Deploy Rancher
################################

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = data.helm_repository.rancher_latest.metadata[0].name
  namespace  = "cattle-system"
  chart      = "rancher"
  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }
  set {
    name  = "hostname"
    value = azurerm_public_ip.frontend.fqdn
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
