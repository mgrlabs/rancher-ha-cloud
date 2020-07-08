#  Rancher API
provider "rancher2" {
  api_url    = var.rancher_api_url
  token_key  = var.rancher_api_token
  insecure = true
}

// Azure credentials
resource "rancher2_cloud_credential" "azure" {
  name = "Azure Cloud Credentials"
  description = "Azure Cloud Credentials"
  azure_credential_config {
    client_id = var.client_id
    client_secret = var.client_secret
    subscription_id = var.subscription_id
  }
}

resource "rancher2_node_template" "azure" {
  name = "Azure Small Node"
  description = "Azure small node template"
  cloud_credential_id = rancher2_cloud_credential.azure.id
  azure_config {
    location = "australiaeast"
    availability_set = "rancher2-rke-as"
    update_domain_count = "2"
    resource_group = "static-rke-test-rg"
    managed_disks = false
    vnet = "static-vnet-test-rg:mgr-static-vnet"
    subnet_prefix = "10.2.0.0/24"
    subnet = "cluster-subnet"
    size = "Standard_D2s_v3"
    open_port = [
      "6443/tcp",
      "2379/tcp",
      "2380/tcp",
      "8472/udp",
      "4789/udp",
      "9796/tcp",
      "10256/tcp",
      "10250/tcp","10251/tcp","10252/tcp",]
    static_public_ip = true
    no_public_ip = true
    use_private_ip = true
  }
}