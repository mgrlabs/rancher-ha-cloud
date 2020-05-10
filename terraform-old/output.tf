
output "k8s_nodes_names" {
  value = azurerm_virtual_machine.rke.*.name
}

output "k8s_nodes_private_ips" {
  value = azurerm_network_interface.rke.*.private_ip_address
}

output "bastion_node_public_ip" {
  value = azurerm_public_ip.frontend.ip_address
}

# Credentials
output "admin" {
  value = var.admin_name
}

# DNS
output "fqdn" {
  value = azurerm_public_ip.frontend.fqdn
}


output "k8s_apiserver_url" {
  value       = "https://${azurerm_public_ip.frontend.fqdn}:6443"
  description = "K8s Server URL"
}

output "k8s_admin_user" {
  value       = rke_cluster.cluster.kube_admin_user
  description = "K8s Admin user"
}

output "client_cert" {
  value       = rke_cluster.cluster.client_cert
  description = "K8s Client Cert"
}

output "ca_crt" {
  value       = rke_cluster.cluster.ca_crt
  description = "K8s CA Cert"
}