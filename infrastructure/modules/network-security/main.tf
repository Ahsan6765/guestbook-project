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

# Micro-segmentation NSG: only the ACA subnet may reach
# MySQL (3306) and ACR/Key Vault (443) private endpoints.
resource "azurerm_network_security_group" "pe" {
  name                = "nsg-pe-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allow_mysql_from_aca" {
  name                        = "Allow-MySQL-From-ACA"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = var.aca_subnet_prefix
  destination_address_prefix  = var.pe_subnet_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.pe.name
}

resource "azurerm_network_security_rule" "allow_https_from_aca" {
  name                        = "Allow-HTTPS-From-ACA"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.aca_subnet_prefix
  destination_address_prefix  = var.pe_subnet_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.pe.name
}

# Overrides the platform default AllowVNetInBound (priority 65000):
# every other subnet in the VNet is blocked from the PE subnet.
resource "azurerm_network_security_rule" "deny_other_vnet_to_pe" {
  name                        = "Deny-Other-VNet-To-PE"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = var.pe_subnet_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.pe.name
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = var.pe_subnet_id
  network_security_group_id = azurerm_network_security_group.pe.id
}