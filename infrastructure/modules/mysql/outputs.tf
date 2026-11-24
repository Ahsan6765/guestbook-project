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

output "admin_username" {
  value = var.admin_login
}

output "admin_password" {
  value     = random_password.admin.result
  sensitive = true
}