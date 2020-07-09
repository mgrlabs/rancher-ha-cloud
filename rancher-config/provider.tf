#  Rancher API
provider "rancher2" {
  version   = "1.9.0"
  api_url   = local.rancher_api_url
  token_key = var.rancher_api_token
  insecure  = true
}
