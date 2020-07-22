################################
# Variables
################################

# Cloud Region/Environment

variable "region" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "environment" {
  type        = string
  description = "The envrionment the resources will be deployed into. e.g Dev, Test, Prod."
}

# Nodes

variable "node_image_sku" {
  type        = map
  description = "The Azure image SKU of Ubuntu to deploy to the Kubernetes nodes."

  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "node_count" {
  type        = string
  description = "Number of Kubernetes nodes to deploy to host Rancher."

  default = "1"
}

variable "node_vm_size" {
  type        = string
  description = "Azure VM size of the worker nodes"

  default = "Standard_B2ms"
}

variable "node_docker_version" {
  type        = string
  description = "Version of Docker to deploy to k8s nodes."

  default = "19.03"
}

# Administrator Credentials

variable "linux_username" {
  type        = string
  description = "Administrator account name on the linux nodes."

  default = "rancheradmin"
}

variable rancher_subnet {
  type        = string
  description = "The name of the subnet the Rancher HA cluster will be deployed into."

  default = "Application"
}

variable azure_service_principal_client_secret {
  type        = string
  description = "description"
}

variable azure_service_principal_client_id {
  type        = string
  description = "description"
}

variable "tags" {
  type        = map
  default     = {}
  description = "Set of base tags that will be associated with each supported resource."
}