output "aca_nsg_id" {
  value = azurerm_network_security_group.aca.id
}

output "pe_nsg_id" {
  value = azurerm_network_security_group.pe.id
}