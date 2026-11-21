variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "name_suffix" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "server_version" {
  type    = string
  default = "8.0.21"

  validation {
    condition     = contains(["8.0.21", "8.0.35"], var.server_version)
    error_message = "Use a supported Azure Database for MySQL Flexible Server version."
  }
}

variable "storage_size_gb" {
  type    = number
  default = 32

  validation {
    condition     = var.storage_size_gb >= 20 && var.storage_size_gb <= 16384
    error_message = "MySQL storage size must be between 20 GB and 16384 GB."
  }
}

variable "backup_retention_days" {
  type    = number
  default = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "MySQL backup retention must be between 1 and 35 days."
  }
}

variable "database_name" {
  type    = string
  default = "guestbook_db"

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,64}$", var.database_name))
    error_message = "The database name must contain 1-64 letters, numbers, underscores, or hyphens."
  }
}

variable "admin_login" {
  type    = string
  default = "sqladmin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_-]{1,31}$", var.admin_login))
    error_message = "The MySQL administrator login must start with a letter and contain 2-32 letters, numbers, underscores, or hyphens."
  }
}

variable "public_network_access" {
  description = "Whether public network access is enabled for MySQL Flexible Server"
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "public_network_access must be either Enabled or Disabled."
  }
}

variable "enable_entra_admin" {
  description = "Registers the application identity as Entra administrator of the server"
  type        = bool
  default     = true
}

variable "app_identity_name" {
  type = string
}

variable "app_identity_id" {
  type = string
}

variable "app_identity_object_id" {
  type = string
}

variable "tags" {
  type = map(string)
}