# Cloud general
variable cloud {
  type        = string
  description = "Cloud provider. Accepted values: 'aws' or 'azure'."
}

variable environment {
  type        = string
  default     = "dev"
  description = "Environment for the specified cloud."
}

variable rancher_region {
  type        = string
  description = "Region for the specified cloud."

  default = "australiaeast"
}

# Rancher Control Plane
variable rancher_api_token {
  type        = string
  description = "description"
}

# Azure specific
variable azure_service_principal_client_id {
  type        = string
  description = "description"

  default = ""
}

variable azure_service_principal_client_secret {
  type        = string
  description = "description"

  default = null
}

variable azure_subscription_id {
  type        = string
  description = "description"

  default = ""
}

variable azure_tenant_id {
  type        = string
  description = "description"

  default = ""
}

variable azure_node_sizes {
  type        = list(map(string))
  description = "description"
}

variable regions {
  type        = list(map(string))
  description = "description"
}

# AWS specific
variable aws_access_key {
  type        = string
  description = "description"

  default = ""
}

variable aws_secret_key {
  type        = string
  description = "description"

  default = ""
}


variable open_ports {
  type        = list
  description = "description"

  default = [
    "6443/tcp",
    "2379/tcp",
    "2380/tcp",
    "8472/udp",
    "4789/udp",
    "9796/tcp",
    "10256/tcp",
    "10250/tcp",
    "10251/tcp",
    "10252/tcp",
  ]
}

variable node_image_urn {
  type        = string
  description = "description"

  default = "canonical:UbuntuServer:18.04-LTS:latest"
}
