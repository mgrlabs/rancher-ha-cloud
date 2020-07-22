terraform {
  required_providers {
    azurerm = "~> 2.0"
  }
}

provider "azurerm" {
  version = "=2.19.0"
  features {}
}

provider "tls" {
  version = "=2.1.1"
}

provider "null" {
  version = "2.1.2"
}