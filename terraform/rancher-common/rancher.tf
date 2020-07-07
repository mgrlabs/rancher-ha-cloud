################################
# Rancher Bootstrap
################################

# Random password for admin account
resource "random_password" "rancher" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "local_file" "random_password" {
  filename = "${path.root}/password.txt"
  content  = random_password.rancher.result
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