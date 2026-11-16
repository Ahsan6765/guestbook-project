resource "azurerm_container_registry" "registry" {
  name                = lower(replace("acr${var.project}${var.environment}${var.name_suffix}", "-", ""))
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"

  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = true

  tags = var.tags
}