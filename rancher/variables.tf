variable "company_prefix" {
  type        = string
  default     = "mgr"
  description = "(Required) Prefix given to all globally unique names."
}

variable "arm_client_secret" {
  type        = string
  description = "Secret for the supplied Service Principal."
}

# variable "arm_location" {
#   type        = string
#   description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
#   default     = "Australia East"
# }

variable "environment" {
  type        = string
  default     = "dev"
  description = "The envrionment the resources will be deployed into. e.g Dev, Test, Prod."
}

variable "rancher_node_count" {
  type        = string
  description = "Number of Kubernetes nodes to deploy."
  default     = "1"
}