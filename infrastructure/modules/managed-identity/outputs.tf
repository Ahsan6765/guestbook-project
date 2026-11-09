output "id" {
  value = azurerm_user_assigned_identity.app.id
}

output "name" {
  value = azurerm_user_assigned_identity.app.name
}

output "client_id" {
  value = azurerm_user_assigned_identity.app.client_id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.app.principal_id
}