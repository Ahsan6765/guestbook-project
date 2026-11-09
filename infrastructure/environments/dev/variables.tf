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
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "address_space" {
  type    = list(string)
  default = ["10.30.0.0/16"]
}

variable "aca_subnet_prefix" {
  type    = string
  default = "10.30.0.0/26"
}

variable "pe_subnet_prefix" {
  type    = string
  default = "10.30.1.0/28"
}

variable "internal_ingress_only" {
  description = "True makes the environment and ingress private to the VNet"
  type        = bool
  default     = false
}

variable "log_retention_in_days" {
  type    = number
  default = 30
}

variable "mysql_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "mysql_storage_size_gb" {
  type    = number
  default = 32
}

variable "mysql_backup_retention_days" {
  type    = number
  default = 7
}

variable "mysql_database_name" {
  type    = string
  default = "appdb"
}

variable "container_image" {
  description = "Initial image; replaced by the CI/CD pipeline after first apply"
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "container_cpu" {
  type    = number
  default = 0.5
}

variable "container_memory" {
  type    = string
  default = "1Gi"
}

variable "health_probe_path" {
  type    = string
  default = "/"
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "http_concurrent_requests_per_replica" {
  type    = number
  default = 50
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