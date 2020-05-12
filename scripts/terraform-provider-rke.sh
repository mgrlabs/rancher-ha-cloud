#!/bin/bash

export PLATFORM=darwin_amd64
export PROVIDER_VERSION=1.0.0-rc5

curl -L "https://github.com/rancher/terraform-provider-rke/releases/download/${PROVIDER_VERSION}/terraform-provider-rke_darwin-amd64" -o ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_v${PROVIDER_VERSION}
chmod +x ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_v${PROVIDER_VERSION}
