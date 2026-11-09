data "azurerm_client_config" "current" {}

resource "random_password" "admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_mysql_flexible_server" "server" {
  name                = "sql-${var.project}-${var.environment}-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = var.sku_name
  version  = var.server_version
  zone     = "1"

  administrator_login    = var.admin_login
  administrator_password = random_password.admin.result

  identity {
    type         = "UserAssigned"
    identity_ids = [var.app_identity_id]
  }

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false

  public_network_access = "Disabled"

  storage {
    size_gb = var.storage_size_gb
  }

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "app" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.server.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# The application identity becomes the Entra administrator of the server,
# enabling passwordless connections from the container app.
resource "azurerm_mysql_flexible_server_active_directory_administrator" "app" {
  count = var.enable_entra_admin ? 1 : 0

  server_id   = azurerm_mysql_flexible_server.server.id
  identity_id = var.app_identity_id
  login       = var.app_identity_name
  object_id   = var.app_identity_object_id
  tenant_id   = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "link-mysql-${var.project}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "mysql" {
  name                = "pe-mysql-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-mysql-${var.project}-${var.environment}"
    private_connection_resource_id = azurerm_mysql_flexible_server.server.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdzg-mysql"
    private_dns_zone_ids = [azurerm_private_dns_zone.mysql.id]
  }
}

resource "azurerm_key_vault_secret" "username" {
  name         = "sql-${var.environment}-username"
  value        = var.admin_login
  key_vault_id = var.key_vault_id
  content_type = "text/plain"
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "password" {
  name         = "sql-${var.environment}-password"
  value        = random_password.admin.result
  key_vault_id = var.key_vault_id
  content_type = "text/plain"
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "connection_string" {
  name         = "sql-${var.environment}-connection-string"
  value        = "mysql://${urlencode(var.admin_login)}:${urlencode(random_password.admin.result)}@${azurerm_mysql_flexible_server.server.fqdn}:3306/${var.database_name}?ssl=true"
  key_vault_id = var.key_vault_id
  content_type = "text/plain"
  tags         = var.tags
}
