terraform {
  required_version = "~> 1.0.7"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 2.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.56"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.11"
    }
  }
}
