/*
Tfvars file for Azure Development environment.

Terraform expects the following environment variables to be exposed specific to the environment being deployed into:

TF_VAR_rancher_api_token=<rancher_api_token>
*/

# Environment specific
product     = "rancher"
cloud       = "azure"
environment = "dev"
region      = "australiaeast"

node_config_etcd = {
  quantity             = "3"
  vm_size              = "Standard_D2_v3"
  disk_type            = "Standard_LRS"
  disk_size            = "30"
  subnet_name          = "Application"
  fault_update_domains = "2"
}

node_config_control = {
  quantity             = "2"
  vm_size              = "Standard_D2_v3"
  disk_type            = "Standard_LRS"
  disk_size            = "30"
  subnet_name          = "Application"
  fault_update_domains = "2"
}

node_config_worker = {
  quantity             = "1"
  vm_size              = "Standard_D2_v3"
  disk_type            = "Standard_LRS"
  disk_size            = "30"
  subnet_name          = "Application"
  fault_update_domains = "2"
}