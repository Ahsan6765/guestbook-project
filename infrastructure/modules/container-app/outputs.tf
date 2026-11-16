output "id" {
  value = azurerm_container_app.app.id
}

output "name" {
  value = azurerm_container_app.app.name
}

output "latest_revision_fqdn" {
  value = azurerm_container_app.app.latest_revision_fqdn
}

output "outbound_ip_addresses" {
  description = "Current outbound IP addresses used by the Container App for external connections."
  value       = azurerm_container_app.app.outbound_ip_addresses
}