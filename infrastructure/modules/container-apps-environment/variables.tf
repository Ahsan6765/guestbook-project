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

variable "log_analytics_workspace_id" {
  type = string
}

variable "infrastructure_subnet_id" {
  type = string
}

variable "internal_load_balancer_enabled" {
  description = "True restricts ingress to the virtual network only"
  type        = bool
  default     = false
}

variable "tags" {
  type = map(string)
}