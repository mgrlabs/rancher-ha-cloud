# Product specific
variable product {
  type        = string
  description = "Name of the product/solution that will be hosted on the cluster."
}

# Cloud general
variable cloud {
  type        = string
  description = "Cloud provider. Accepted values: 'aws' or 'azure'."
}

variable environment {
  type        = string
  description = "Environment for the specified cloud."
}

variable region {
  type        = string
  description = "Region for the specified cloud."

  default = "australiaeast"
}

# Azure
variable "tags" {
  type        = map
  default     = {}
  description = "Set of base tags that will be associated with each supported resource."
}

variable subscription_id {
  type        = string
  description = "description"
}


# Rancher Control Plane
variable rancher_api_token {
  type        = string
  description = "description"
}

variable rancher_region {
  type        = string
  description = "Region for the specified cloud."

  default = "westus"
}

# Nodes
variable node_config_etcd {
  type        = map
  description = "description"
}

variable node_config_control {
  type        = map
  description = "description"
}

variable node_config_worker {
  type        = map
  description = "description"
}
