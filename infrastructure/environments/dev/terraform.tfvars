# Azure Authentication
# Replace the placeholder GUID with your actual Subscription ID from the Azure Portal.
subscription_id = "xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Core Identifiers
project     = "myapp"
environment = "dev"
app_name    = "core-api"
location    = "eastus"

# Network Architecture
# A /16 provides ample room for future subnets. 
# We use /24 for the subnets to ensure we never run out of IP addresses for Container Apps or Private Endpoints.
address_space     = ["10.50.0.0/16"]
aca_subnet_prefix = "10.50.0.0/24"
pe_subnet_prefix  = "10.50.1.0/24"

# Ingress Configuration
# Set to false for Dev so you can test the public endpoint from your browser/Postman.
internal_ingress_only = false

# Observability
log_retention_in_days = 7

# Database Configuration (Azure Database for MySQL Flexible Server)
# B_Standard_B1ms is the most cost-effective burstable SKU for Dev workloads.
mysql_sku_name              = "B_Standard_B1ms"
mysql_storage_size_gb       = 32
mysql_backup_retention_days = 2
mysql_database_name         = "core_db"

# Container App Compute & Image
# The placeholder image will be replaced by your CI/CD pipeline later.
# Port 8080 is the standard convention for modern backend APIs (Node, Python, Java, Go).
container_image   = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_port    = 8080
container_cpu     = 0.5
container_memory  = "1Gi"
health_probe_path = "/health"

# Autoscaling Rules
min_replicas                         = 1
max_replicas                         = 3
http_concurrent_requests_per_replica = 100

# Application Environment Variables
# These are injected directly into the container at runtime.
env_vars = {
  APP_ENV                 = "development"
  LOG_LEVEL               = "debug"
  CORS_ALLOWED_ORIGINS    = "*"
  DB_CONNECTION_POOL_SIZE = "10"
  ENABLE_SWAGGER_UI       = "true"
}