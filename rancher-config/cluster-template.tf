resource "rancher2_cluster_template" "cluster_template_azure" {
  name = "cluster-template-rke-azure"
  #members {  }

  template_revisions {
    name    = "v1"
    default = true
    enabled = true
    #labels = {    }
    cluster_config {
      cluster_auth_endpoint {
        enabled = true
      }
      default_cluster_role_for_project_members = null
      default_pod_security_policy_template_id  = null
      desired_agent_image                      = ""
      desired_auth_image                       = ""
      docker_root_dir                          = "/var/lib/docker"
      enable_cluster_alerting                  = false
      enable_cluster_monitoring                = true
      enable_network_policy                    = false
      rke_config {
        ignore_docker_version = true
        addon_job_timeout     = "30"
        kubernetes_version    = "v1.17.6-rancher2-1"
        #prefix_path
        ssh_agent_auth = "false"
        authentication {
          strategy = "x509|webhook"
        }
        monitoring {
          provider = "metrics-server"
        }
        ingress {
          provider = "nginx"
          node_selector = {
            app = "ingress"
          }

        }
        network {
          plugin = "canal"
        }
        services {
          etcd {
            creation  = "12h"
            retention = "72h"
            snapshot  = false
            backup_config {
              enabled        = true
              interval_hours = "12"
              retention      = "6"
              safe_timestamp = false
            }
          }
          kube_api {
            service_node_port_range = "30000-32767"
            pod_security_policy     = false
            always_pull_images      = false
          }
        }
        upgrade_strategy {
          drain                        = true
          max_unavailable_worker       = "10%"
          max_unavailable_controlplane = "1"
          drain_input {
            delete_local_data  = false
            force              = false
            grace_period       = "-1"
            ignore_daemon_sets = true
            timeout            = "120"
          }
        }
      }
      scheduled_cluster_scan {
        enabled = true
        scan_config {
          cis_scan_config {
            debug_master               = false
            debug_worker               = false
            override_benchmark_version = "rke-cis-1.4"
            profile                    = "permissive"
          }
        }
        schedule_config {
          cron_schedule = "0 0 * * *"
          retention     = "24"
        }
      }
    }
  }

  template_revisions {
    name    = "v2"
    default = false
    enabled = true
    #labels = {    }
    cluster_config {
      cluster_auth_endpoint {
        enabled = true
      }
      default_cluster_role_for_project_members = null
      default_pod_security_policy_template_id  = null
      desired_agent_image                      = ""
      desired_auth_image                       = ""
      docker_root_dir                          = "/var/lib/docker"
      enable_cluster_alerting                  = false
      enable_cluster_monitoring                = true
      enable_network_policy                    = false
      rke_config {
        ignore_docker_version = true
        addon_job_timeout     = "30"
        kubernetes_version    = "v1.17.6-rancher2-1"
        #prefix_path
        ssh_agent_auth = "false"
        authentication {
          strategy = "x509|webhook"
        }
        monitoring {
          provider = "metrics-server"
        }
        ingress {
          provider = "nginx"
          node_selector = {
            app = "ingress"
          }

        }
        network {
          plugin = "canal"
        }
        services {
          etcd {
            creation  = "12h"
            retention = "72h"
            snapshot  = false
            backup_config {
              enabled        = true
              interval_hours = "12"
              retention      = "6"
              safe_timestamp = false
            }
          }
          kube_api {
            service_node_port_range = "30000-32767"
            pod_security_policy     = false
            always_pull_images      = false
          }
        }
        upgrade_strategy {
          drain                        = true
          max_unavailable_worker       = "10%"
          max_unavailable_controlplane = "1"
          drain_input {
            delete_local_data  = false
            force              = false
            grace_period       = "-1"
            ignore_daemon_sets = true
            timeout            = "120"
          }
        }
      }
      scheduled_cluster_scan {
        enabled = true
        scan_config {
          cis_scan_config {
            debug_master               = false
            debug_worker               = false
            override_benchmark_version = "rke-cis-1.4"
            profile                    = "permissive"
          }
        }
        schedule_config {
          cron_schedule = "0 0 * * *"
          retention     = "24"
        }
      }
    }
  }

  template_revisions {
    name    = "v3"
    default = false
    enabled = true
    #labels = {    }
    cluster_config {
      cluster_auth_endpoint {
        enabled = true
      }
      default_cluster_role_for_project_members = null
      default_pod_security_policy_template_id  = null
      desired_agent_image                      = ""
      desired_auth_image                       = ""
      docker_root_dir                          = "/var/lib/docker"
      enable_cluster_alerting                  = false
      enable_cluster_monitoring                = true
      enable_network_policy                    = false
      rke_config {
        ignore_docker_version = true
        addon_job_timeout     = "30"
        kubernetes_version    = "v1.17.6-rancher2-1"
        #prefix_path
        ssh_agent_auth = "false"
        authentication {
          strategy = "x509|webhook"
        }
        monitoring {
          provider = "metrics-server"
        }
        ingress {
          provider = "nginx"
          node_selector = {
            app = "ingress"
          }

        }
        network {
          plugin = "canal"
        }
        services {
          etcd {
            creation  = "12h"
            retention = "72h"
            snapshot  = false
            backup_config {
              enabled        = true
              interval_hours = "12"
              retention      = "6"
              safe_timestamp = false
            }
          }
          kube_api {
            service_node_port_range = "30000-32767"
            pod_security_policy     = false
            always_pull_images      = false
          }
        }
        upgrade_strategy {
          drain                        = true
          max_unavailable_worker       = "10%"
          max_unavailable_controlplane = "1"
          drain_input {
            delete_local_data  = false
            force              = false
            grace_period       = "-1"
            ignore_daemon_sets = true
            timeout            = "120"
          }
        }
      }
      scheduled_cluster_scan {
        enabled = true
        scan_config {
          cis_scan_config {
            debug_master               = false
            debug_worker               = false
            override_benchmark_version = "rke-cis-1.4"
            profile                    = "permissive"
          }
        }
        schedule_config {
          cron_schedule = "0 0 * * *"
          retention     = "24"
        }
      }
    }
  }

  description = "Terraform cluster template cluster-template-k8s"

}