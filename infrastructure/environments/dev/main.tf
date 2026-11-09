data "azurerm_client_config" "current" {}

resource "random_string" "unique_suffix" {
  length  = 4
  special = false
  upper   = false
}

# 1. Resource Group
module "resource_group" {
  source = "../../modules/resource-group"

  project     = var.project
  environment = var.environment
  location    = var.location
  tags        = var.tags
}

# 2. Networking
module "networking" {
  source = "../../modules/networking"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  address_space     = var.address_space
  aca_subnet_prefix = var.aca_subnet_prefix
  pe_subnet_prefix  = var.pe_subnet_prefix

  tags = var.tags
}

# 3. Network Security
module "network_security" {
  source = "../../modules/network-security"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  aca_subnet_id     = module.networking.aca_subnet_id
  aca_subnet_prefix = var.aca_subnet_prefix
  pe_subnet_id      = module.networking.pe_subnet_id
  pe_subnet_prefix  = var.pe_subnet_prefix

  tags = var.tags
}

# 4. Log Analytics
module "log_analytics" {
  source = "../../modules/log-analytics"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# 5. Managed Identity
module "managed_identity" {
  source = "../../modules/managed-identity"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  tags = var.tags
}

# 6. Container Registry
module "container_registry" {
  source = "../../modules/container-registry"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  pe_subnet_id = module.networking.pe_subnet_id
  vnet_id      = module.networking.vnet_id
  name_suffix  = random_string.unique_suffix.result

  tags = var.tags
}

# 7. Key Vault
module "key_vault" {
  source = "../../modules/key-vault"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  pe_subnet_id = module.networking.pe_subnet_id
  vnet_id      = module.networking.vnet_id
  name_suffix  = random_string.unique_suffix.result

  tags = var.tags
}

# The deploying identity needs permission to write the initial MySQL secrets to Key Vault
resource "azurerm_role_assignment" "deployer_kv_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# 8. MySQL Database
module "mysql" {
  source = "../../modules/mysql"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  pe_subnet_id = module.networking.pe_subnet_id
  vnet_id      = module.networking.vnet_id
  key_vault_id = module.key_vault.id
  name_suffix  = random_string.unique_suffix.result

  sku_name              = var.mysql_sku_name
  storage_size_gb       = var.mysql_storage_size_gb
  backup_retention_days = var.mysql_backup_retention_days
  database_name         = var.mysql_database_name

  app_identity_name      = module.managed_identity.name
  app_identity_id        = module.managed_identity.id
  app_identity_object_id = module.managed_identity.principal_id

  tags = var.tags

  depends_on = [azurerm_role_assignment.deployer_kv_secrets_officer]
}

# 9. Container Apps Environment
module "container_apps_environment" {
  source = "../../modules/container-apps-environment"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  log_analytics_workspace_id     = module.log_analytics.id
  infrastructure_subnet_id       = module.networking.aca_subnet_id
  internal_load_balancer_enabled = var.internal_ingress_only

  tags = var.tags
}

# 10. Container App
module "container_app" {
  source = "../../modules/container-app"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  app_name                     = var.app_name
  container_app_environment_id = module.container_apps_environment.id
  identity_id                  = module.managed_identity.id
  registry_login_server        = module.container_registry.login_server

  image                    = var.container_image
  container_port           = var.container_port
  container_cpu            = var.container_cpu
  container_memory         = var.container_memory
  ingress_external_enabled = !var.internal_ingress_only
  health_probe_path        = var.health_probe_path

  min_replicas                         = var.min_replicas
  max_replicas                         = var.max_replicas
  http_concurrent_requests_per_replica = var.http_concurrent_requests_per_replica

  env_vars = var.env_vars

  key_vault_secrets = [
    {
      name                = "sql-${var.environment}-connection-string"
      key_vault_secret_id = module.mysql.connection_string_secret_versionless_id
    }
  ]

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.app_acr_pull,
    azurerm_role_assignment.app_kv_secrets_user,
  ]
}

# 11. Role Assignments for the Application Identity
resource "azurerm_role_assignment" "app_acr_pull" {
  scope                = module.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "app_kv_secrets_user" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.principal_id
}

# 12. Diagnostic Settings
locals {
  diagnostic_targets = {
    container-registry = module.container_registry.id
    key-vault          = module.key_vault.id
    mysql              = module.mysql.server_id
  }
}

resource "azurerm_monitor_diagnostic_setting" "platform_diagnostics" {
  for_each = local.diagnostic_targets

  name                       = "diag-${each.key}-${var.project}-${var.environment}"
  target_resource_id         = each.value
  log_analytics_workspace_id = module.log_analytics.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}