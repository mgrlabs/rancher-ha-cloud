FROM ubuntu:18.04

ARG TERRAFORM_VERSION=0.12.24
ARG TERRAGRUNT_VERSION=0.23.10
ARG HELM_VERSION=3.1.2
ARG KUBECTL_VERSION=v1.18.2
ARG RKE_VERSION=0.2.10

# Install base requirements
RUN apt-get update && \
      apt-get install -y \
      curl \
      sudo \
      unzip

WORKDIR /tmp

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Installs latest version of Terraform unless version is provided as argument
RUN TERRAFORM_VERSION=${TERRAFORM_VERSION:-$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | \
        grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')}; \
        curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
        unzip terraform.zip -d /usr/local/bin && rm terraform.zip

# HELM: Installs latest version of Helm unless version is provided as argument
RUN HELM_VERSION=${HELM_VERSION:-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | \
        grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')}; \
        curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
        tar xvf helm.tar.gz --strip 1 -C /usr/local/bin && rm helm.tar.gz

# KUBECTL: Installs latest version of Kubectl unless version is provided as argument
RUN KUBECTL_VERSION=${KUBECTL_VERSION:-$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)}; \
      curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
          chmod +x kubectl && mv ./kubectl /usr/local/bin

# RKE: Installs latest version of RKE unless version is provided as argument
RUN RKE_VERSION=${RKE_VERSION:-$(curl -s https://api.github.com/repos/rancher/rke/releases/latest | \
        grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')}; \
        curl -LO https://github.com/rancher/rke/releases/download/v${RKE_VERSION}/rke_linux-amd64 -O && \
        chmod +x ./rke_linux-amd64 && mv ./rke_linux-amd64 /usr/local/bin/rke

# TERRAGRUNT: Installs latest version unless version is provided as argument
RUN TERRAGRUNT_VERSION=${TERRAGRUNT_VERSION:-$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | \
        grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')}; \
        curl -LO https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O && \
        chmod +x ./terragrunt_linux_amd64 && mv ./terragrunt_linux_amd64 /usr/local/bin/terragrunt
