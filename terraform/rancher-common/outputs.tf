################################
# Outputs
################################

output rke_cluster_config {
  value       = local.rke_kube_config_yaml
  sensitive   = true
  description = "description"
}

output rancher_admin_password {
  value       = random_password.rancher.result
  sensitive   = true
  description = "description"
}
