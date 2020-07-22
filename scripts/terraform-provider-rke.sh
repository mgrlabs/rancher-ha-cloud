#!/bin/bash

export PLATFORM=darwin_amd64
export PROVIDER_VERSION=1.0.1

curl -L "https://github.com/rancher/terraform-provider-rke/releases/download/v${PROVIDER_VERSION}/terraform-provider-rke_${PROVIDER_VERSION}_darwin_amd64.zip" -o ~/.terraform.d/plugins/${PLATFORM}/terraform-provider-rke.zip
unzip ~/.terraform.d/plugins/${PLATFORM}/terraform-provider-rke.zip -d ~/.terraform.d/plugins/${PLATFORM}
rm ~/.terraform.d/plugins/${PLATFORM}/terraform-provider-rke.zip
chmod +x ~/.terraform.d/plugins/${PLATFORM}/terraform-provider-rke_v${PROVIDER_VERSION}
