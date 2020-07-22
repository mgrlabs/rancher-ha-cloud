################################
# Rancher Bootstrap
################################

# Random password for admin account
resource "random_password" "rancher" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Arbitrary wait to allow Rancher to become ready
resource "null_resource" "rancher" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [
    helm_release.rancher
  ]
}

# Initialize Rancher server
resource "rancher2_bootstrap" "admin_password" {
  password  = random_password.rancher.result
  telemetry = true

  depends_on = [
    null_resource.rancher
  ]
}