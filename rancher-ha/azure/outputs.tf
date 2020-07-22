################################
# Outputs
################################

output "rancher_azure_nodes_names" {
  value       = azurerm_linux_virtual_machine.rancher.*.name
  description = "Azure node names as presented in the portal."
}

output "rancher_linux_host_names" {
  value       = azurerm_linux_virtual_machine.rancher.*.computer_name
  description = "Hostnames for the linux nodes that will host Rancher."
}

output "rancher_nodes_private_ips" {
  value       = azurerm_network_interface.rancher.*.private_ip_address
  description = "Private IP addresses of the nodes that will host Rancher."
}

output "linux_username" {
  value       = var.linux_username
  description = "Admin username configured Rancher nodes."
}

output tls_private_key {
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
  description = "SSH RSA Private key for bastion authentication."
}

output load_balancer_fqdn {
  value       = trimsuffix(azurerm_private_dns_a_record.rancher.fqdn, ".")
  description = "The FQDN of the DNS A Record."
}

output load_balancer_private_ip {
  value       = azurerm_lb.rancher.private_ip_address
  description = "The private IP assigned to the Load Balancer."
}

output rancher_admin_api_token {
  value       = module.rancher_common.rancher_admin_api_token
  sensitive   = true
  description = "description"
}

output rancher_admin_password {
  value       = module.rancher_common.rancher_admin_password
  sensitive   = true
  description = "description"
}
