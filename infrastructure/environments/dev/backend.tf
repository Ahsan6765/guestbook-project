terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-myapp-dev"
    storage_account_name = "stmyappdev"
    container_name       = "tfstate"
    key                  = "dev/infrastructure.tfstate"

    use_azuread_auth = true
  }
}