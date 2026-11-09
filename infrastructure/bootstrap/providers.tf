terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Bootstrap intentionally uses LOCAL state.
  # Its only job is to create the remote state home.
}

provider "azurerm" {
  storage_use_azuread = true

  features {}
}