################################
# Locals
################################

locals {
  rke_kube_config_yaml = replace(rke_cluster.rancher.kube_config_yaml, "/server:.*/", "server: \"https://${var.load_balancer_private_ip}:6443\"")
}
