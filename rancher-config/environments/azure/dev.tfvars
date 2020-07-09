azure_subscription_id = "cc10292a-7bfe-40c5-ad3f-01bdccc8ad03"
cloud                 = "azure"
environment           = "dev"
rancher_region        = "australiaeast"
regions = [
  {
    region               = "australiaeast"
    fault_update_domains = "2"
    subnet_name          = "Application"
    subnet_cidr          = "10.200.66.0/23"
  },
  {
    region               = "westus"
    fault_update_domains = "2"
    subnet_name          = "Application"
    subnet_cidr          = "10.202.66.0/23"
  }
]
azure_node_sizes = [
  {
    node_size_name    = "small"
    node_vm_size      = "Standard_B2ms"
    node_disk_size    = "30"
    node_storage_type = "Standard_LRS"
  },
  {
    node_size_name    = "medium"
    node_vm_size      = "Standard_B4ms"
    node_disk_size    = "60"
    node_storage_type = "Standard_LRS"
  },
  {
    node_size_name    = "large"
    node_vm_size      = "Standard_F8s_v2"
    node_disk_size    = "90"
    node_storage_type = "Premium_LRS"
  },
]