data "azurerm_client_config" "current" {}

resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "time_sleep" "role_assignment_propagation" {
  create_duration = "30s"

  depends_on = [
    azurerm_role_assignment.deployer_kv_secrets_officer,
    azurerm_role_assignment.app_acr_pull,
    azurerm_role_assignment.app_kv_secrets_user,
  ]
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

  tags = var.tags
}

# 3. Network Security
module "network_security" {
  source = "../../modules/network-security"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  aca_subnet_id = module.networking.aca_subnet_id

  tags = var.tags
}

# 4. Managed Identity
module "managed_identity" {
  source = "../../modules/managed-identity"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  tags = var.tags
}

# 5. Container Registry
module "container_registry" {
  source = "../../modules/container-registry"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  name_suffix = random_string.unique_suffix.result

  tags = var.tags
}

# 6. Key Vault
module "key_vault" {
  source = "../../modules/key-vault"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  name_suffix                   = random_string.unique_suffix.result
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  public_network_access_enabled = var.key_vault_public_network_access_enabled

  tags = var.tags
}

# The deploying identity needs permission to write the initial MySQL secrets to Key Vault
resource "azurerm_role_assignment" "deployer_kv_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# 7. MySQL Database
module "mysql" {
  source = "../../modules/mysql"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  key_vault_id = module.key_vault.id
  name_suffix  = random_string.unique_suffix.result

  sku_name              = var.mysql_sku_name
  storage_size_gb       = var.mysql_storage_size_gb
  backup_retention_days = var.mysql_backup_retention_days
  database_name         = var.mysql_database_name
  public_network_access = var.mysql_public_network_access

  app_identity_name      = module.managed_identity.name
  app_identity_id        = module.managed_identity.id
  app_identity_object_id = module.managed_identity.principal_id

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.deployer_kv_secrets_officer,
    time_sleep.role_assignment_propagation,
  ]
}

# 8. Container Apps Environment
module "container_apps_environment" {
  source = "../../modules/container-apps-environment"

  project             = var.project
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  infrastructure_subnet_id = module.networking.aca_subnet_id

  tags = var.tags

  depends_on = [module.network_security]
}

# 9. Container App
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

  image             = var.container_image
  container_port    = var.container_port
  container_cpu     = var.container_cpu
  container_memory  = var.container_memory
  health_probe_path = var.health_probe_path

  min_replicas                         = var.min_replicas
  max_replicas                         = var.max_replicas
  http_concurrent_requests_per_replica = var.http_concurrent_requests_per_replica

  env_vars = merge(var.env_vars, {
    PORT    = tostring(var.container_port)
    DB_HOST = module.mysql.server_fqdn
    DB_PORT = "3306"
    DB_NAME = module.mysql.database_name
    DB_SSL  = "true"
  })

  key_vault_secrets = [
    {
      name                 = "sql-${var.environment}-username"
      environment_variable = "DB_USER"
      key_vault_secret_id  = module.mysql.username_secret_versionless_id
    },
    {
      name                 = "sql-${var.environment}-password"
      environment_variable = "DB_PASSWORD"
      key_vault_secret_id  = module.mysql.password_secret_versionless_id
    }
  ]

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.app_acr_pull,
    azurerm_role_assignment.app_kv_secrets_user,
    time_sleep.role_assignment_propagation,
  ]
}

# 10. Role Assignments for the Application Identity
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
