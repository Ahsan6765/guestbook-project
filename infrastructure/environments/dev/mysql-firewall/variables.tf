variable "subscription_id" {
  description = "Subscription hosting the development resources"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the MySQL server and Container App"
  type        = string
}

variable "mysql_server_name" {
  description = "Name of the MySQL Flexible Server"
  type        = string
}

variable "container_app_egress_ips" {
  description = "Current outbound IPv4 addresses of the deployed Container App"
  type        = set(string)

  validation {
    condition     = length(var.container_app_egress_ips) > 0 && alltrue([for ip in var.container_app_egress_ips : can(cidrnetmask("${ip}/32"))])
    error_message = "Provide at least one valid Container Apps outbound IPv4 address."
  }
}
