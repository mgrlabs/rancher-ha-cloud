################################
# Outputs
################################

output "k8s_nodes_names" {
  value = azurerm_virtual_machine.rancher_ha.*.name
  description = "Names of the K8s nodes."
}

output "k8s_nodes_private_ips" {
  value = azurerm_network_interface.rancher_ha.*.private_ip_address
  description = "Private IPs of the K8s nodes."
}

output "bastion_node_public_ip" {
  value = azurerm_public_ip.frontend.ip_address
  description = "Public IP of the Load Balancer for SSH."
}

output "admin_name" {
  value = var.admin_name
  description = "Admin username configured for Bastion and K8s nodes."
}

output "lb_rancher_fqdn" {
  value = azurerm_public_ip.frontend.fqdn
  description = "FQDN of the Azure Load Balancer NIC."
}

output tls_private_key {
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
  description = "SSH RSA Private key for bastion authentication."
}

output domain_name_prefix {
  value       = azurerm_public_ip.frontend.domain_name_label
  description = "description"
}
