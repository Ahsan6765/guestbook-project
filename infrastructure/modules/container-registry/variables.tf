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

variable "name_suffix" {
  description = "Short uniqueness suffix for globally scoped names"
  type        = string
}

variable "tags" {
  type = map(string)
}