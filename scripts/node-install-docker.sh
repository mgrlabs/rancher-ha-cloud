#!/bin/bash

# Created to install Docker onto nodes that will host Rancher in a HA cluster
# https://docs.docker.com/engine/install/ubuntu/

# Install Docker dependencies
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add docker stable repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install specific version of Docker
sudo apt-get update
sudo apt-get install -y docker-ce=5:${docker_version}~3-0~ubuntu-bionic docker-ce-cli=5:${docker_version}~3-0~ubuntu-bionic containerd.io

# Allow logged in user to execute Docker
sudo usermod -a -G docker ${linux_username}