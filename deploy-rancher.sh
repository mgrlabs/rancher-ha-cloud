#!/bin/bash

export PLATFORM=darwin_amd64
export PROVIDER_VERSION=1.0.0-rc5
curl -L "https://github.com/rancher/terraform-provider-rke/releases/download/${PROVIDER_VERSION}/terraform-provider-rke_darwin-amd64" -o ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_v${PROVIDER_VERSION}
chmod +x ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_v${PROVIDER_VERSION}

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl --kubeconfig=kube_config_cluster.yml create namespace cert-manager
kubectl --kubeconfig=kube_config_cluster.yml create namespace cattle-system

kubectl --kubeconfig=kube_config_cluster.yml apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager.crds.yaml

helm --kubeconfig ./kube_config_cluster.yml install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.14.1

helm --kubeconfig ./kube_config_cluster.yml upgrade rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set ingress.tls.source="rancher" \
  --set hostname="mgrlabsrancherprod.australiaeast.cloudapp.azure.com" \
  --set auditLog.level="1" \
  --set addLocal="true" \
  --wait