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

variable "name_suffix" {
  type = string
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled on the Key Vault"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Number of days deleted Key Vault objects remain recoverable"
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Key Vault soft-delete retention must be between 7 and 90 days."
  }
}

variable "public_network_access_enabled" {
  description = "Whether the Key Vault public network endpoint is enabled"
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
}