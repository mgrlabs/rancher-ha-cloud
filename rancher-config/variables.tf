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
  default     = "dev"
  description = "Environment for the specified cloud."
}


# Rancher Control Plane
variable rancher_api_token {
  type        = string
  description = "description"
}

variable rancher_region {
  type        = string
  description = "Region for the specified cloud."

  default = "australiaeast"
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

# variable azure_node_sizes {
#   type        = list(map(string))
#   description = "description"
# }

# variable regions {
#   type        = list(map(string))
#   description = "description"
# }

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

# variable open_ports {
#   type        = list
#   description = "description"

#   default = [
#     "6443/tcp",
#     "2379/tcp",
#     "2380/tcp",
#     "8472/udp",
#     "4789/udp",
#     "9796/tcp",
#     "10256/tcp",
#     "10250/tcp",
#     "10251/tcp",
#     "10252/tcp",
#   ]
# }

# variable node_image_urn {
#   type        = string
#   description = "description"

#   default = "canonical:UbuntuServer:18.04-LTS:latest"
# }

# Github authentication
variable github_client_id {
  type        = string
  description = "(Required/Sensitive) Github auth Client ID (string)"
}

variable github_client_secret {
  type        = string
  description = "(Required/Sensitive) Github auth Client secret (string)"
}

# Get the ID of a GitHub org: curl https://api.github.com/orgs/ArkoseLabs
# Get the ID of a GitHub user: curl https://api.github.com/users/inmamind
variable github_role_mappings {
  type        = map
  default     = {}
  description = "(Optional) Allowed principal ids for auth. Required if access_mode is required or restricted. Ex: github_user://<USER_ID> github_team://<GROUP_ID> github_org://<ORG_ID> (list)"
}
