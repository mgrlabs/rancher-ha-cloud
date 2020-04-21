nodes:
  - address: ${node_private_address_1}
    hostname_override: ${hostname_override_1}
    user: ${node_user_name}
    role: [controlplane,etcd,worker]
    ssh_key_path: ${ssh_key_path}
  - address: ${node_private_address_2}
    hostname_override: ${hostname_override_2}
    user: ${node_user_name}
    role: [controlplane,etcd,worker]
    ssh_key_path: ${ssh_key_path}
  - address: ${node_private_address_3}
    hostname_override: ${hostname_override_3}
    user: ${node_user_name}
    role: [controlplane,etcd,worker]
    ssh_key_path: ${ssh_key_path}

cluster_name: mycluster

authentication:
  strategy: x509
  sans:
    - "${load_balancer_fqdn}"

bastion_host:
  address: 20.188.217.151
  user: ${node_user_name}
  port: 22
  ssh_key_path: ${ssh_key_path}

network:
  plugin: canal

ingress:
  provider: nginx

cloud_provider:
  name: azure
  azureCloudProvider:
    tenantId: "${azure_tenant_id}"
    subscriptionId: "${azure_subscription_id}"
    aadClientId: "${azure_client_id}"
    aadClientSecret: "${azure_client_secret}"
