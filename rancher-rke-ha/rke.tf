################################
# RKE Deployment
################################

# Limited to a 3 node configuration until this can be made dynamic
data "template_file" "rke" {
  template = "${file("${path.module}/templates/cluster.yml.tpl")}"
  vars = {
    node_private_address_1 = azurerm_network_interface.rke.*.private_ip_address[0]
    hostname_override_1    = azurerm_virtual_machine.rke.*.name[0]
    node_private_address_2 = azurerm_network_interface.rke.*.private_ip_address[1]
    hostname_override_2    = azurerm_virtual_machine.rke.*.name[1]
    node_private_address_3 = azurerm_network_interface.rke.*.private_ip_address[2]
    hostname_override_3    = azurerm_virtual_machine.rke.*.name[2]
    node_user_name         = var.administrator_username
    load_balancer_fqdn     = azurerm_public_ip.frontend.fqdn
    rke_cluster_name       = var.loadbalancer_dns_prefix
    bastion_public_ip      = azurerm_public_ip.frontend.ip_address
    azure_tenant_id        = lookup(var.azure_service_principal, "tenant_id")
    azure_subscription_id  = lookup(var.azure_service_principal, "subscription_id")
    azure_client_id        = lookup(var.azure_service_principal, "client_id")
    azure_client_secret    = lookup(var.azure_service_principal, "client_secret")
  }
}

resource "local_file" "rke_config" {
  content  = data.template_file.rke.rendered
  filename = "${path.module}/cluster.yml"
}

resource "null_resource" "rke_up" {
  provisioner "local-exec" {
    command = "rke up"
  }

  depends_on = [
    local_file.rke_config,
    azurerm_virtual_machine.rke
  ]
}

data "local_file" "rke_kube_config" {
  filename = "${path.module}/kube_config_cluster.yml"
  depends_on = [
    null_resource.rke_up
  ]
}

resource "local_file" "rke_replace" {
  content  = replace(data.local_file.rke_kube_config.content, "/server:.*/", "server: \"https://${azurerm_public_ip.frontend.fqdn}:6443\"")
  filename = "${path.module}/../kube_config_cluster.yml"

  depends_on = [
    data.local_file.rke_kube_config
  ]
}
