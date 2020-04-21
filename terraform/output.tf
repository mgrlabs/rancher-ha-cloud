# Supporting Software
# output "rke_version" {
#   value = var.rke_version
# }

# output "docker_version" {
#   value = var.docker_version
# }

# Azure Location
output "resource_group" {
  value = var.azure_resource_group
}

# Node Public IPs, Private IPs, Hostnames
# output "etcd_nodes" {
#   value = azurerm_public_ip.etcd.*.ip_address
# }

# output "etcd_node_names" {
#   value = azurerm_virtual_machine.etcd.*.name
# }

# output "etcd_node_privateips" {
#   value = azurerm_network_interface.etcd.*.private_ip_address
# }

# output "controlplane_nodes" {
#   value = azurerm_public_ip.control_plane.*.ip_address
# }

output "rke_nodes_names" {
  value = azurerm_virtual_machine.rke.*.name
}

output "rke_nodes_private_ips" {
  value = azurerm_network_interface.rke.*.private_ip_address
}

# output "rke_nodes_public_ips" {
#   value = azurerm_public_ip.rke.*.ip_address
# }

output "worker_node_names" {
  value = azurerm_virtual_machine.rke.*.name
}

# output "bastion_node_public_ip" {
#   value = azurerm_public_ip.bastion.ip_address
# }

# Credentials

output "admin" {
  value = var.administrator_username
}

# output "ssh" {
#   value = var.administrator_ssh
# }

# output "administrator_ssh_private" {
#   value = var.administrator_ssh_private
# }

# DNS
output "fqdn" {
  value = azurerm_public_ip.frontend.fqdn
}

# Let's Encrypt
# output "letsencrypt_email" {
#   value = var.letsencrypt_email
# }

# output "letsencrypt_environment" {
#   value = var.letsencrypt_environment
# }
