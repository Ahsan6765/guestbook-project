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

variable "pe_subnet_id" {
  type = string
}

variable "vnet_id" {
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
}

variable "storage_size_gb" {
  type    = number
  default = 32
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "database_name" {
  type    = string
  default = "appdb"
}

variable "admin_login" {
  type    = string
  default = "sqladmin"
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