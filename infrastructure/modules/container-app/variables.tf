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

variable "app_name" {
  type    = string
  default = "api"
}

variable "container_app_environment_id" {
  type = string
}

variable "identity_id" {
  type = string
}

variable "registry_login_server" {
  type = string
}

variable "image" {
  type = string
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
  type    = map(string)
  default = {}
}

variable "secret_names" {
  description = "Non-sensitive names of secrets configured directly on the Container App"
  type        = set(string)
  default = []
}

variable "secrets" {
  description = "Secret values configured directly on the Container App; Terraform state contains these values"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "secret_env_vars" {
  description = "Environment variable names mapped to Container App secret names"
  type        = map(string)
  default     = {}
}

variable "tags" {
  type = map(string)
}