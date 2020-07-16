/*
Tfvars file for Azure Development environment.

Terraform expects the following environment variables to be exposed specific to the environment being deployed into:

TF_VAR_azure_service_principal_client_id=<client_id>
TF_VAR_azure_service_principal_client_secret=<client_secret>
*/

# Environment specific
region      = "australiaeast"
environment = "dev"
node_count  = "1"