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

variable "ingress_external_enabled" {
  type    = bool
  default = true
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

variable "key_vault_secrets" {
  description = "Key Vault backed secrets injected as environment variables"
  type = list(object({
    name                = string
    key_vault_secret_id = string
  }))
  default = []
}

variable "tags" {
  type = map(string)
}