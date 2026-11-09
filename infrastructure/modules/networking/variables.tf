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

variable "address_space" {
  type = list(string)
}

variable "aca_subnet_prefix" {
  type = string
}

variable "pe_subnet_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}