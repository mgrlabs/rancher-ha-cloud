module azure_cluster {
  source         = "../clouds/azure"
  environment    = var.environment
  k8s_node_count = var.k8s_node_count
}
