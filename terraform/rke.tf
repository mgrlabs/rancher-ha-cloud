data "template_file" "rke" {
  template = "${file("${path.module}/templates/cluster.yml.tpl")}"
  vars = {
    node_private_address_1 = azurerm_network_interface.rke.*.private_ip_address[0]
    hostname_override_1 = azurerm_virtual_machine.rke.*.name[0]
    node_private_address_2 = azurerm_network_interface.rke.*.private_ip_address[1]
    hostname_override_2 = azurerm_virtual_machine.rke.*.name[1]
    node_private_address_3 = azurerm_network_interface.rke.*.private_ip_address[2]
    hostname_override_3 = azurerm_virtual_machine.rke.*.name[2]
    node_user_name = var.administrator_username
    load_balancer_fqdn = azurerm_public_ip.frontend.fqdn
    bastion_public_ip = azurerm_public_ip.frontend.ip_address
    ssh_key_path = "~/.ssh/id_rsa"
    azure_tenant_id = lookup(var.azure_service_principal, "tenant_id")
    azure_subscription_id = lookup(var.azure_service_principal, "subscription_id")
    azure_client_id = lookup(var.azure_service_principal, "client_id")
    azure_client_secret = lookup(var.azure_service_principal, "client_secret")
  }
}

resource "local_file" "rke" {
    content     = data.template_file.rke.rendered
    filename = "${path.module}/cluster.yml"
}
