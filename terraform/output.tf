
output "rke_nodes_names" {
  value = azurerm_virtual_machine.rke.*.name
}

output "rke_nodes_private_ips" {
  value = azurerm_network_interface.rke.*.private_ip_address
}

output "worker_node_names" {
  value = azurerm_virtual_machine.rke.*.name
}

output "bastion_node_public_ip" {
  value = azurerm_public_ip.frontend.ip_address
}

# Credentials
output "admin" {
  value = var.administrator_username
}

# DNS
output "fqdn" {
  value = azurerm_public_ip.frontend.fqdn
}
