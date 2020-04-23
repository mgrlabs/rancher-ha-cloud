provider "rke" {
  version = "v1.0.0-rc5"
}

resource "rke_cluster" "cluster" {
  nodes {
    address = "40.126.228.127"
    internal_address = "10.0.1.4"
    hostname_override = "node-worker-0"
    user    = "mgradmin"
    role    = ["worker"]
    ssh_key = file("~/.ssh/id_rsa")
  }
  nodes {
    address = "23.101.214.218"
    internal_address = "10.0.1.6"
    hostname_override = "node-controlplane-0"
    user    = "mgradmin"
    role    = ["controlplane"]
    ssh_key = file("~/.ssh/id_rsa")
  }
  nodes {
    address = "40.126.237.18"
    internal_address = "10.0.1.5"
    hostname_override = "node-etcd-0"
    user    = "mgradmin"
    role    = ["etcd"]
    ssh_key = file("~/.ssh/id_rsa")
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = rke_cluster.cluster.kube_config_yaml
}
