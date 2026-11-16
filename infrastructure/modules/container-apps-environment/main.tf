resource "azurerm_container_app_environment" "environment" {
  name                = "cae-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  # With no Log Analytics workspace configured, Container Apps streams logs only.
  infrastructure_subnet_id = var.infrastructure_subnet_id

  tags = var.tags
}
