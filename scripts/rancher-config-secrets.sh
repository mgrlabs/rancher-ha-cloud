#!/bin/bash
ENVIRONMENT="dev"
REGION="westus"

export TF_VAR_rancher_api_token=$(az keyvault secret show --vault-name ${ENVIRONMENT}-${REGION}-rancher-kv --name rancherApiToken --query value -o tsv)
export TF_VAR_github_client_secret=$(az keyvault secret show --vault-name ${ENVIRONMENT}-${REGION}-rancher-kv --name gitHubClientSecret --query value -o tsv)
export TF_VAR_github_client_id=$(az keyvault secret show --vault-name ${ENVIRONMENT}-${REGION}-rancher-kv --name gitHubClientId --query value -o tsv)