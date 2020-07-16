/*
Tfvars file for Azure Development environment.

Terraform expects the following environment variables to be exposed specific to the environment being deployed into:

TF_VAR_azure_tenant_id=<tenant_id>
TF_VAR_azure_service_principal_client_id=<client_id>
TF_VAR_azure_service_principal_client_secret=<client_secret>
TF_VAR_rancher_api_token=<rancher_api_token>
*/

# Environment specific
azure_subscription_id = "cc10292a-7bfe-40c5-ad3f-01bdccc8ad03"
cloud                 = "azure"
environment           = "test"
rancher_region        = "australiaeast"
product               = "funcaptcha"

github_role_mappings = {
  "github_org://5441327" = "admin"
}
