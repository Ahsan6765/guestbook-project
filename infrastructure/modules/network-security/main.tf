# Baseline NSG for the Container Apps subnet.
# Intentionally rule-free: the ACA environment requires outbound
# management traffic. A deny-all outbound here breaks the environment.
resource "azurerm_network_security_group" "aca" {
  name                = "nsg-aca-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aca" {
  subnet_id                 = var.aca_subnet_id
  network_security_group_id = azurerm_network_security_group.aca.id
}
