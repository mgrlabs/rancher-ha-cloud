/*
Tfvars file for Azure Development environment.

Terraform expects the following environment variables to be exposed specific to the environment being deployed into:

TF_VAR_azure_tenant_id=<tenant_id>
TF_VAR_azure_service_principal_client_id=<client_id>
TF_VAR_azure_service_principal_client_secret=<client_secret>
TF_VAR_rancher_api_token=<rancher_api_token>
TF_VAR_github_client_secret=<github_client_secret>
TF_VAR_github_client_id=<github_client_id>

*/

# Environment specific
azure_subscription_id = "ee080ef7-a10d-47a3-83be-29330decee8d"
cloud                 = "azure"
environment           = "dev"
rancher_region        = "westus"

github_role_mappings = {
  "github_org://5441327" = "admin"
}
