output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "aca_subnet_id" {
  value = azurerm_subnet.aca.id
}

output "pe_subnet_id" {
  value = azurerm_subnet.pe.id
}