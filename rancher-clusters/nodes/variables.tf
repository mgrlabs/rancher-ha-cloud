variable product {
  type        = string
  description = "Name of the product/solution that will be hosted on the cluster."

  default = "funcaptcha"
}

# Cloud general
variable cloud {
  type        = string
  description = "Cloud provider. Accepted values: 'aws' or 'azure'."

  default = "azure"
}

variable environment {
  type        = string
  default     = "dev"
  description = "Environment for the specified cloud."
}

variable region {
  type        = string
  default     = "australiaeast"
  description = "description"
}

variable region_fault_update_domains {
  type        = string
  default     = "2"
  description = "description"
}


# Node template
variable node_image_urn {
  type        = string
  description = "description"

  default = "canonical:UbuntuServer:18.04-LTS:latest"
}

variable node_azure_resource_group {
  type        = string
  description = "description"
}

variable node_vm_size {
  type        = string
  description = "description"
}

variable node_disk_size {
  type        = string
  description = "description"

  default = "30"
}

variable node_disk_type {
  type        = string
  description = "description"
}

# variable node_vnet {
#   type        = string
#   description = "description"
# }

# variable node_vnet_subnet_cidr {
#   type        = string
#   description = "description"
# }

variable node_vnet_subnet_name {
  type        = string
  description = "description"
}

# Node ports inbound
# https://rancher.com/docs/rke/latest/en/os/
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



variable node_role_suffix {
  type        = string
  description = "description"
}


# Node pool
variable rancher_cluster_id {
  type        = string
  description = "description"
}

variable node_quantity {
  type        = string
  description = "description"

  default = "1"
}

# Node roles
variable etcd_enable {
  type        = bool
  description = "description"

  default = false
}

variable control_plane_enable {
  type        = bool
  description = "description"

  default = false
}

variable worker_enable {
  type        = bool
  description = "description"

  default = false
}
