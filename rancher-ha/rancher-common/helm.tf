################################
# Helm Deployments
################################

# Helm - Deploy Cert-Manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "cert-manager"
  chart      = "cert-manager"
  version    = "v${var.cert_manager_version}"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    rke_cluster.rancher,
    kubernetes_namespace.cert_manager
  ]
}

# Helm - Deploy Rancher
resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  namespace  = "cattle-system"
  chart      = "rancher"
  version    = var.rancher_version
  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }
  set {
    name  = "hostname"
    value = var.load_balancer_fqdn
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
    value = length(var.node_azure_names)
  }
  depends_on = [
    helm_release.cert_manager,
    kubernetes_namespace.cattle_system
  ]
}
