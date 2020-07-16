################################
# GitHub Single Sign-on
################################

resource "rancher2_auth_config_github" "github" {
  client_id     = var.github_client_id
  client_secret = var.github_client_secret

  access_mode = "required"

  allowed_principal_ids = keys(var.github_role_mappings)
  enabled               = "true"
  tls                   = true
}

resource "rancher2_global_role_binding" "github" {
  for_each           = var.github_role_mappings
  group_principal_id = each.key
  global_role_id     = each.value
}