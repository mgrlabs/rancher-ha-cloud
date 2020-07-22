/*
Tfvars file for Azure Development environment.

Terraform expects the following environment variables to be exposed specific to the environment being deployed into:

TF_VAR_rancher_api_token=<rancher_api_token>
*/

# Environment specific
product     = "funcaptcha"
cloud       = "azure"
environment = "dev"
region      = "westus"
subscription_id = "ee080ef7-a10d-47a3-83be-29330decee8d"

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