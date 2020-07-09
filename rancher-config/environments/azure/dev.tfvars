azure_subscription_id = "cc10292a-7bfe-40c5-ad3f-01bdccc8ad03"
cloud                 = "azure"
environment           = "dev"
rancher_region        = "australiaeast"
regions = [
  {
    region               = "australiaeast"
    fault_update_domains = "2"
    subnet_name          = "Application"
    subnet_prefix        = "10.200.66.0/23"
  },
  {
    region               = "westus"
    fault_update_domains = "2"
    subnet_name          = "Application"
    subnet_prefix        = "10.202.66.0/23"
  }
]
azure_node_sizes = [
  {
    name         = "small"
    size         = "Standard_B2ms"
    disk_size    = "30"
    storage_type = "Standard_LRS"
  },
  {
    name         = "medium"
    size         = "Standard_B4ms"
    disk_size    = "60"
    storage_type = "Standard_LRS"
  },
  {
    name         = "large"
    size         = "Standard_F8s_v2"
    disk_size    = "90"
    storage_type = "Premium_LRS"
  },
]