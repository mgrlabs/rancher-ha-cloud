# Supporting Software 
# RKE Version
variable "rke_version" {
  type        = string
  description = "version of Rancher Kubernetes Engine (RKE) used to provision Kubernetes"
  default     = "v0.2.10"
}

# Helm Version
# variable "helm_version" {
#   type        = string
#   description = "Version of Helm to use to provision Rancher"
#   default     = "v2.16.6"
# }

# Docker Version
variable "docker_version" {
  type        = string
  description = "Version of Docker to use to provision Rancher"
  default     = "19.03.8"
}

# Authorization Variables for the Terraform Azure Provider
variable "azure_service_principal" {
  type        = map
  description = "Azure Service Principal under which Terraform will be executed."

}

# Location
variable "azure_region" {
  type        = string
  description = "Azure region where all infrastructure will be provisioned."
  default     = "Australia East"
}

variable "azure_resource_group" {
  type        = string
  description = "Name of the Azure Resource Group to be created for the network."
  default     = "rg-rancher-rke-ha"
}

# Node Sizes
variable "rke_node_vm_size" {
  type        = string
  description = "Azure VM size of the worker nodes"
  default     = "Standard_B2s"
  # default     = "Standard_D2s_v3"
}

variable "bastion_node_vm_size" {
  type        = string
  description = "Azure VM size of the control plane nodes"
  default     = "Standard_B2s"
}

# variable "etcd_node_vm_size" {
#   type        = string
#   description = "Azure VM size of the etcd nodes"
#   default     = "Standard_B2s"
# }


# Counts of desired node types for Kubernetes
variable "rke_node_count" {
  type        = string
  description = "Number of workers to be created by Terraform."
  default     = "3"
}

# variable "rke_controlplane_count" {
#   type        = string
#   description = "Number of control plane nodes to be created by Terraform."
#   default     = "1"
# }

# variable "rke_etcd_count" {
#   type        = string
#   description = "Number of etcd nodes to be created by Terraform."
#   default     = "1"
# }

# Administrator Credentials
variable "administrator_username" {
  type        = string
  description = "Administrator account name on the linux nodes."
  default     = "mgradmin"
}

# variable "administrator_ssh" {
#   type        = string
#   description = "SSH Public Key for the Administrator account."
# }

# variable "administrator_ssh_private" {
#   type        = string
#   description = "The path to the SSH Private Key file."
# }

variable "loadbalancer_dns_label" {
  type        = string
  description = "DNS hostname label used to create a fqdn for the frontendloadbalancer"

  default = "mgrrancherhatest"
}

# variable "letsencrypt_email" {
#   type = string
#   description = "e-mail address for let's encrypt"
# }

# variable "letsencrypt_environment" {
#   type = string
#   description = "Environment type for let's encrypt"
#   default = "staging"
# }

