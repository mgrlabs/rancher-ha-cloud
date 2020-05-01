variable "company_prefix" {
  type        = string
  default     = "mgr-rancher-demo"
  description = "(Required) Prefix given to all globally unique names"
}

variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "Australia East"
}

variable "azure_resource_group" {
  type        = string
  default     = "rg-arkose-rancher-rke"
  description = "Name of the Azure Resource Group to be created for the network."
}

variable "docker_version" {
  type        = string
  default     = "18.09.9"
  description = "Version of Docker to use to provision Rancher"
}

# variable "azure_service_principal" {
#   type        = map
#   description = "Azure Service Principal under which Terraform will be executed."
# }

variable "rke_node_vm_size" {
  type        = string
  description = "Azure VM size of the worker nodes"

  default = "Standard_D2s_v3"
}

variable "bastion_node_vm_size" {
  type        = string
  description = "Azure VM size of the control plane nodes"

  default = "Standard_B2s"
}

# Counts of desired node types for Kubernetes
variable "rke_node_count" {
  type        = string
  description = "Number of workers to be created by Terraform."

  default = "3"
}

# Administrator Credentials
variable "administrator_username" {
  type        = string
  description = "Administrator account name on the linux nodes."

  default = "mgrdemo"
}

variable "loadbalancer_dns_prefix" {
  type        = string
  description = "DNS hostname label used to create a fqdn for the frontendloadbalancer"

  default = "servianrancherdemo"
}

variable "rke_node_image_sku" {
  type        = string
  default     = "18.04-LTS"
  description = "The version of Ubuntu to deploy to the RKE nodes."
}