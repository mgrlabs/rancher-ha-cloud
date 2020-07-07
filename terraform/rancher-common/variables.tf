################################
# Variables
################################

# Cluster config
variable service_principal_client_id {
  type        = string
  default     = ""
  description = "description"
}

variable "service_principal_client_secret" {
  type        = string
  description = "Secret for the supplied Service Principal."
}

variable service_principal_tenant_id {
  type        = string
  default     = ""
  description = "description"
}

variable service_principal_subscription_id {
  type        = string
  default     = ""
  description = "description"
}

# variable node_hostnames {
#   type        = list
#   description = "description"
# }

variable node_azure_names {
  type        = list
  description = "description"
}

variable node_ip_addresses {
  type        = list
  description = "description"
}

variable load_balancer_private_ip {
  type        = string
  description = "description"
}

# variable linux_username {
#   type        = string
#   default     = ""
#   description = "description"
# }

variable node_ssh_private_key {
  type        = string
  description = "description"
}

variable load_balancer_fqdn {
  type        = string
  description = "description"
}

# Rancher config
variable rancher_version {
  type        = string
  default     = "2.4.5"
  description = "description"
}

variable cert_manager_version {
  type        = string
  default     = "0.15.1"
  description = "description"
}
