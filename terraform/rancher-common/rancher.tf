################################
# Rancher Bootstrap
################################

# Random password for admin account
resource "random_password" "rancher" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Initialize Rancher server
resource "rancher2_bootstrap" "admin_password" {
  depends_on = [
    helm_release.rancher
  ]

  provider = rancher2.bootstrap

  password  = random_password.rancher.result
  telemetry = true
}