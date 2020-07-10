/*
Tfvars file for Azure Development environment.

Terraform expects the following environment variables to be exposed specific to the environment being deployed into:

TF_VAR_azure_tenant_id=<tenant_id>
TF_VAR_azure_service_principal_client_id=<client_id>
TF_VAR_azure_service_principal_client_secret=<client_secret>
TF_VAR_rancher_api_token=<rancher_api_token>
*/

# Environment specific
azure_subscription_id = "afaf5574-d002-4f62-b073-e90ccc4abc4e"
cloud                 = "azure"
environment           = "prod"
rancher_region        = "australiaeast"

# Regions the environment deploys into
regions = [
  {
    region               = "australiaeast"
    fault_update_domains = "2"
    subnet_name          = "Application"
    subnet_cidr          = "10.200.66.0/23"
  },
  {
    region               = "westus"
    fault_update_domains = "3"
    subnet_name          = "Application"
    subnet_cidr          = "10.202.66.0/23"
  }
]

# The size combinations that will be deployed into each region
azure_node_sizes = [
  {
    node_size_name    = "xsmall-c2m4"
    node_vm_size      = "Standard_B2s"
    node_disk_size    = "30"
    node_storage_type = "Standard_LRS"
  },
  {
    node_size_name    = "small-c2m8"
    node_vm_size      = "Standard_B2ms"
    node_disk_size    = "30"
    node_storage_type = "Standard_LRS"
  },
  {
    node_size_name    = "medium-c4m16"
    node_vm_size      = "Standard_B4ms"
    node_disk_size    = "60"
    node_storage_type = "Standard_LRS"
  },
  {
    node_size_name    = "large-c8m32"
    node_vm_size      = "Standard_B8ms"
    node_disk_size    = "90"
    node_storage_type = "Premium_LRS"
  },
]