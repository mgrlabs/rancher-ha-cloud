#!/bin/bash

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

helm --kubeconfig ./kube_config_cluster.yml upgrade rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set ingress.tls.source="rancher" \
  --set hostname="servianrancherdemo.australiaeast.cloudapp.azure.com" \
  --set auditLog.level="1" \
  --set addLocal="true" \
  --wait