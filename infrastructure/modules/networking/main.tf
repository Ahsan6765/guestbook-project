resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

# Dedicated subnet for the Container Apps environment.
# Never shared with any other service.
resource "azurerm_subnet" "aca" {
  name                 = "snet-aca-${var.project}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aca_subnet_prefix]

  delegation {
    name = "Microsoft.App.environments"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Hosts every private endpoint NIC: ACR, Key Vault, MySQL.
resource "azurerm_subnet" "pe" {
  name                 = "snet-pe-${var.project}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.pe_subnet_prefix]

  # Keeps NSG enforcement active on private endpoint NICs.
  private_endpoint_network_policies = "Enabled"
}
