output "state_resource_group" {
  description = "Resource group containing the Terraform state storage account"
  value       = azurerm_resource_group.tfstate.name
}

output "state_storage_account" {
  description = "Storage account hosting Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "state_container" {
  description = "Blob container hosting Terraform state"
  value       = azurerm_storage_container.tfstate.name
}