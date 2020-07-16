################################
# Providers - Rancher Common
################################

# Random provider for rancher password generation
provider "random" {
  version = "2.2.1"
}

# REQUIRES: ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_vX.X.X
provider "rke" {
  version = "1.0.0"
}

# Kubernetes provider
provider "kubernetes" {
  version = "1.11.3"

  load_config_file       = "false"
  host                   = "https://${var.load_balancer_private_ip}:6443"
  username               = rke_cluster.rancher.kube_admin_user
  client_certificate     = rke_cluster.rancher.client_cert
  client_key             = rke_cluster.rancher.client_key
  cluster_ca_certificate = rke_cluster.rancher.ca_crt
}

provider "helm" {
  version = "1.2.3"
  kubernetes {

    load_config_file       = "false"
    host                   = "https://${var.load_balancer_private_ip}:6443"
    username               = rke_cluster.rancher.kube_admin_user
    client_certificate     = rke_cluster.rancher.client_cert
    client_key             = rke_cluster.rancher.client_key
    cluster_ca_certificate = rke_cluster.rancher.ca_crt
  }
}

# Rancher2 bootstrapping provider
provider "rancher2" {
  version   = "1.9.0"
  api_url   = "https://${var.load_balancer_fqdn}"
  insecure  = true
  bootstrap = true
}