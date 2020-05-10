variable "company_prefix" {
  type        = string
  default     = "mgr"
  description = "(Required) Prefix given to all globally unique names."
}

variable "arm_location" {
  type        = string
  default     = "Australia East"
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "environment" {
  type        = string
  description = "The envrionment the resources will be deployed into. e.g Dev, Test, Prod."
}

################################
# Kubernetes
################################

variable "k8s_docker_version" {
  type        = string
  default     = "19.03.8"
  description = "Version of Docker to deploy to k8s nodes."
}

variable "k8s_ubuntu_sku" {
  type        = string
  default     = "18.04-LTS"
  description = "The Azure image SKU of Ubuntu to deploy to the Kubernetes nodes."
}

variable "k8s_node_vm_size" {
  type        = string
  description = "Azure VM size of the worker nodes"
  default     = "Standard_D2s_v3"
}

variable "k8s_node_count" {
  type        = string
  description = "Number of Kubernetes nodes to deploy."
}

################################
# Remote Admin
################################

variable "bastion_vm_size" {
  type        = string
  description = "Azure VM size of the control plane nodes"
  default     = "Standard_B1ms"
}

# Administrator Credentials
variable "admin_name" {
  type        = string
  description = "Administrator account name on the linux nodes."
  default     = "rancheradmin"
}
