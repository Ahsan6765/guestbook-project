# Private endpoint connectivity requires the Premium SKU.
resource "azurerm_container_registry" "registry" {
  name                = lower(replace("acr${var.project}${var.environment}${var.name_suffix}", "-", ""))
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"

  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false
  retention_policy_in_days      = 3

  tags = var.tags
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link_acr" {
  name                = "link-acr-${var.project}-${var.environment}"
  private_dns_zone_id = azurerm_private_dns_zone.dns_zone_acr.id
  virtual_network_id  = var.vnet_id
  registration_enabled = false
  tags                = var.tags
}

resource "azurerm_private_endpoint" "private_endpoint_acr" {
  name                = "pe-acr-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-acr-${var.project}-${var.environment}"
    private_connection_resource_id = azurerm_container_registry.main_acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdzg-acr"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone_acr.id]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns_link_acr]
}