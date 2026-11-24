# Azure Authentication
# Supply the real target subscription ID in a local, untracked tfvars file.
subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Core Identifiers
project     = "myapp"
environment = "dev"
app_name    = "core-api"
location    = "eastus"

# Network Architecture
address_space     = ["10.50.0.0/16"]
aca_subnet_prefix = "10.50.0.0/24"

# Database Configuration
mysql_sku_name              = "B_Standard_B1ms"
mysql_storage_size_gb       = 20
mysql_backup_retention_days = 2
mysql_database_name         = "guestbook_db"
mysql_public_network_access = "Enabled"

# Container App Compute & Image
container_image   = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_port    = 5000
container_cpu     = 0.5
container_memory  = "1Gi"
health_probe_path = "/health/live"

# Autoscaling Rules
min_replicas                         = 1
max_replicas                         = 3
http_concurrent_requests_per_replica = 100

# Application Environment Variables
env_vars = {
  APP_ENV                 = "development"
  LOG_LEVEL               = "debug"
  CORS_ALLOWED_ORIGINS    = "*"
  DB_CONNECTION_POOL_SIZE = "10"
  ENABLE_SWAGGER_UI       = "true"
}