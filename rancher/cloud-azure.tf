module azure_cluster {
  source         = "../clouds/azure"
  arm_location   = "Australia East"
  environment    = var.environment
  k8s_node_count = var.k8s_node_count
  company_prefix = var.company_prefix
}
