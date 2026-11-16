data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main_kv" {
  name                = "kv-${var.project}-${var.environment}-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  public_network_access_enabled = true
  tags                          = var.tags
}
