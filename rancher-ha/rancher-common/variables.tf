################################
# Variables
################################

# Azure cloud config
variable azure_service_principal_client_id {
  type        = string
  description = "Client ID of the Service Principal used for the Azure cloud provider."
}

variable azure_service_principal_client_secret {
  type        = string
  description = "Secret of the Service Principal used for the Azure cloud provider."
}

variable azure_tenant_id {
  type        = string
  description = "Tenant ID of the Service Principal used for the Azure cloud provider."
}

variable azure_subscription_id {
  type        = string
  description = "Subscription ID that the Service Principal used for the Azure cloud provider has access to."
}

# RKE node config
variable node_azure_names {
  type        = list
  description = "Azure resource names of the VMs to host Rancher."
}

variable node_ip_addresses {
  type        = list
  description = "Private IP addresses of the VMs to host Rancher."
}

variable node_ssh_private_key {
  type        = string
  description = "SSH Private Key PEM for access to the VMs to host Rancher."
}

variable linux_username {
  type        = string
  description = "The username that has access to the Linux nodes to host Rancher."
}

# Load balancer config
variable load_balancer_private_ip {
  type        = string
  description = "The Private IP address of the internal load balancer that will load balance Rancher API/UX and kubeapi traffic."
}

variable load_balancer_fqdn {
  type        = string
  description = "The fully-qualified domain name of the internal load balancer that will load balance Rancher API/UX and kubeapi traffic."
}

# Rancher config
variable rancher_version {
  type        = string
  default     = "2.4.5"
  description = "The version of the Rancher helm chart to install."
}

variable cert_manager_version {
  type        = string
  default     = "0.15.1"
  description = "The version of the Cert-Manager helm chart to install."
}

variable rke_depends_on {
  type        = list
  description = "Dummy depends_on to force wait for data drive initialisation to complete."
}
