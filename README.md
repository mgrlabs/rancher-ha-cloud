# rancher-ha-cloud

![rancher-ha-cloud](https://github.com/ArkoseLabs/rancher-ha-cloud/workflows/rancher-ha-cloud/badge.svg?branch=master)

This repo contains the Terraform infra as code to deploy a Rancher HA Control plane into a given environment.

## Current functionality (Azure):
- Deploy *n* number of Ubuntu 18.04 VMs to a new Resource Group and Azure
- Create an NSG, NICs and a load balancer to front end the cluster and Rancher to an existing VNet which is deployed using Azure Foundations.
- Use the Terraform [RKE provider](https://github.com/rancher/terraform-provider-rke) to deploy the RKE-based Kubernetes cluster to the Azure-hosted nodes.
- Use the Terraform [Kubernetes provider](https://www.terraform.io/docs/providers/kubernetes/index.html) to create the required namespaces.
- Use the Terraform [Helm provider](https://www.terraform.io/docs/providers/helm/index.html) to deploy [cert-manager](https://cert-manager.io/docs/) and [Rancher](https://rancher.com/).
- Use the Terraform [Rancher2 provider](https://www.terraform.io/docs/providers/rancher2/index.html) to bootstrap the Rancher cluster with a random password.
- Create a storage account for node diagnostics and push the relevant secrets into a container named `rancher`.

## Folder Structure

```
.
├── Dockerfile
├── README.md
├── images
│   └── azure-logical.png
├── scripts
│   ├── terraform-provider-rke.sh
│   └── what-is-my-ip.sh
├── ssh_private_key
└── terraform
    ├── azure
    │   ├── cloud-config
    │   │   ├── cloud-init.tpl
    │   │   └── node-data-drives.sh
    │   ├── locals.tf
    │   ├── main.tf
    │   ├── networking.tf
    │   ├── nodes.tf
    │   ├── outputs.tf
    │   ├── provider.tf
    │   ├── secrets.tf
    │   └── variables.tf
    ├── cloud-common
    │   └── cloud_init.tpl
    └── rancher-common
        ├── helm.tf
        ├── kubernetes.tf
        ├── locals.tf
        ├── outputs.tf
        ├── provider.tf
        ├── rancher.tf
        ├── rke.tf
        └── variables.tf
```

## Usage
1) Setup your `local.tfvars` to contain the following variables:
```
service_principal_client_secret = "<service_principal_client_secret>"
service_principal_client_id     = "<service_principal_client_id>"
arm_location                    = "australiaeast"
environment                     = "dev"
node_count                      = "1"
```
2. Download the Terraform RKE provider by running the following script:
```sh
./scripts/terraform-provider-rke.sh
```
3. Log into Azure using Azure CLI
```
az login
az account set -s <subscription_id>
```
4. Run Terraform to deploy the cluster to the environment and region as set in the local.tfvars
```
terraform init -var-file=local.tfvars ./terraform/azure
terraform apply -var-file=local.tfvars ./terraform/azure
```