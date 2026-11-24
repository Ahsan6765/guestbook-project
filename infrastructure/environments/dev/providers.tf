# terraform {
#   required_version = ">= 1.9.0"

#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 4.0"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = "~> 3.6"
#     }
#   }
# }

# provider "azurerm" {
#   subscription_id = var.subscription_id

#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = true
#     }

#   }
# }


terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }

  }
}