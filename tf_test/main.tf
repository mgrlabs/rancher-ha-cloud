data "template_file" "rke" {
  template = "${file("${path.module}/cluster.yml.tpl")}"
  vars = {
    node_private_address_1 = "10.0.1.4"
    hostname_override_1 = "node-rke-0"
    node_private_address_2 = "10.0.1.4"
    hostname_override_2 = "node-rke-0"
    node_private_address_3 = "10.0.1.4"
    hostname_override_3 = "node-rke-0"
    node_user_name = "mgradmin"
    load_balancer_fqdn = "www.disney.com"
    ssh_key_path = "~/.ssh/id_rsa"
    azure_tenant_id = "tenant"
    azure_subscription_id = "sub"
    azure_client_id = "clientid"
    azure_client_secret = "secret"
  }
}

resource "local_file" "rke" {
    content     = data.template_file.rke.rendered
    filename = "${path.module}/cluster.yml"
}
