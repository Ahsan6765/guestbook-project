variable "subscription_id" {
  description = "Target Azure subscription"
  type        = string
}

variable "project" {
  type    = string
  default = "myapp"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type    = string
  default = "api"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,31}$", var.app_name))
    error_message = "The app name must start with a letter and contain 2-32 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "address_space" {
  type    = list(string)
  default = ["10.30.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "Provide at least one valid IPv4 CIDR in address_space."
  }
}

variable "aca_subnet_prefix" {
  type    = string
  default = "10.30.0.0/26"

  validation {
    condition     = can(cidrhost(var.aca_subnet_prefix, 0))
    error_message = "aca_subnet_prefix must be a valid IPv4 CIDR."
  }
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection; recommended for production"
  type        = bool
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  description = "Key Vault soft-delete retention in days"
  type        = number
  default     = 7

  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Key Vault soft-delete retention must be between 7 and 90 days."
  }
}

variable "key_vault_public_network_access_enabled" {
  description = "Enable the Key Vault public endpoint"
  type        = bool
  default     = true
}

variable "mysql_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "mysql_storage_size_gb" {
  type    = number
  default = 32

  validation {
    condition     = var.mysql_storage_size_gb >= 20 && var.mysql_storage_size_gb <= 16384
    error_message = "MySQL storage size must be between 20 GB and 16384 GB."
  }
}

variable "mysql_backup_retention_days" {
  type    = number
  default = 7

  validation {
    condition     = var.mysql_backup_retention_days >= 1 && var.mysql_backup_retention_days <= 35
    error_message = "MySQL backup retention must be between 1 and 35 days."
  }
}

variable "mysql_database_name" {
  type    = string
  default = "guestbook_db"

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,64}$", var.mysql_database_name))
    error_message = "The database name must contain 1-64 letters, numbers, underscores, or hyphens."
  }
}

variable "mysql_public_network_access" {
  description = "Public network access mode for the test MySQL server"
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.mysql_public_network_access)
    error_message = "mysql_public_network_access must be either Enabled or Disabled."
  }
}

variable "container_image" {
  description = "Initial image; replaced by the CI/CD pipeline after first apply"
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_port" {
  type    = number
  default = 80

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "container_cpu" {
  type    = number
  default = 0.5

  validation {
    condition     = contains([0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4], var.container_cpu)
    error_message = "container_cpu must be a supported Azure Container Apps CPU value."
  }
}

variable "container_memory" {
  type    = string
  default = "1Gi"

  validation {
    condition     = contains(["0.5Gi", "1Gi", "1.5Gi", "2Gi", "3Gi", "4Gi", "6Gi", "8Gi"], var.container_memory)
    error_message = "container_memory must be a supported Azure Container Apps memory value."
  }
}

variable "health_probe_path" {
  type    = string
  default = "/"
}

variable "min_replicas" {
  type    = number
  default = 1

  validation {
    condition     = var.min_replicas >= 0 && var.min_replicas <= var.max_replicas
    error_message = "min_replicas cannot be negative and cannot exceed max_replicas."
  }
}

variable "max_replicas" {
  type    = number
  default = 3

  validation {
    condition     = var.max_replicas >= 1
    error_message = "max_replicas must be at least 1."
  }
}

variable "http_concurrent_requests_per_replica" {
  type    = number
  default = 50

  validation {
    condition     = var.http_concurrent_requests_per_replica >= 1
    error_message = "http_concurrent_requests_per_replica must be at least 1."
  }
}

variable "env_vars" {
  type = map(string)
  default = {
    APP_ENV   = "dev"
    LOG_LEVEL = "info"
  }
}

variable "tags" {
  type = map(string)
  default = {
    project     = "myapp"
    environment = "dev"
    managed-by  = "terraform"
  }
}