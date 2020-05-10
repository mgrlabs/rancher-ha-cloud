#!/bin/bash
set -e

# https://www.itwonderlab.com/use-your-public-internet-ip-address-terraform
INTERNETIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
jq -n --arg internetip "$INTERNETIP" '{"internet_ip":$internetip}'