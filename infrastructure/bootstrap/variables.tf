variable "project" {
  description = "Project identifier used in resource names"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment identifier used in resource names"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region hosting the state storage account"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags applied to bootstrap resources"
  type        = map(string)
  default = {
    project    = "myapp"
    managed-by = "terraform"
    layer      = "bootstrap"
  }
}