#!/bin/bash
ENVIRONMENT="dev"

export TF_VAR_rancher_api_token=$(az keyvault secret show --vault-name ${ENVIRONMENT}-auea-rancher-kv --name rancherApiToken --query value -o tsv)