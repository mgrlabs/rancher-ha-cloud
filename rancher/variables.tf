variable "company_prefix" {
  type        = string
  description = "(Required) Prefix given to all globally unique names."
  default     = "ACME"
}

variable "arm_location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "Australia East"
}

variable "environment" {
  type        = string
  description = "The envrionment the resources will be deployed into. e.g Dev, Test, Prod."
  default = "Test"
}

variable "arm_client_id" {
  type        = string
  description = "Service Principal identity"
  default     = "f7f15461-5bf8-4be7-bef8-337a1e96ec11"
}

variable "arm_client_secret" {
  type        = string
  description = "Secret for the supplied Service Principal."
  default = "46ceccb0-717f-416e-9b43-13368ee591bf"
}

variable "rancher_node_count" {
  type        = string
  description = "Number of Kubernetes nodes to deploy."
  default     = "1"
}