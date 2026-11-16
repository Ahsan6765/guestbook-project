output "server_id" {
  value = azurerm_mysql_flexible_server.server.id
}

output "server_name" {
  value = azurerm_mysql_flexible_server.server.name
}

output "server_fqdn" {
  value = azurerm_mysql_flexible_server.server.fqdn
}

output "database_name" {
  value = azurerm_mysql_flexible_database.app.name
}

output "username_secret_id" {
  value = azurerm_key_vault_secret.username.id
}

output "username_secret_versionless_id" {
  value = azurerm_key_vault_secret.username.versionless_id
}

output "password_secret_id" {
  value = azurerm_key_vault_secret.password.id
}

output "password_secret_versionless_id" {
  value = azurerm_key_vault_secret.password.versionless_id
}