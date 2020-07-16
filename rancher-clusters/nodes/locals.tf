locals {
  rancher_prefix = "${var.product}-${var.environment}-${var.region}-${var.node_role_suffix}"
  node_prefix    = "${var.environment}-${var.region}-${var.product}-rke-${var.node_role_suffix}"
  vnet_prefix    = "${var.environment}-${var.region}-${var.product}-vnet-rg"

  ports_etcd = [
    "2379/tcp",
    "2380/tcp",
    "8472/udp",
    "10250/tcp",
  ]

  ports_control = [
    "80/tcp",
    "443/tcp",
    "6443/tcp",
    "8472/udp",
    "10250/tcp",
    "2380/tcp",
  ]

  ports_worker = [
    "80/tcp",
    "443/tcp",
    "6443/tcp",
    "8472/udp",
    "10250/tcp",
    "2380/tcp",
  ]
}
