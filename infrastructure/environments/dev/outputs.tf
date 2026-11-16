output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "aca_subnet_id" {
  value = module.networking.aca_subnet_id
}

output "acr_login_server" {
  value = module.container_registry.login_server
}

output "key_vault_uri" {
  value = module.key_vault.uri
}

output "app_identity_client_id" {
  value = module.managed_identity.client_id
}

output "app_identity_principal_id" {
  value = module.managed_identity.principal_id
}

output "container_app_environment_id" {
  value = module.container_apps_environment.id
}

output "container_app_name" {
  value = module.container_app.name
}

output "container_app_fqdn" {
  value = module.container_app.latest_revision_fqdn
}

output "container_app_outbound_ip_addresses" {
  description = "Current Container Apps outbound IPv4 addresses; reconciled by the mysql-firewall environment root."
  value       = module.container_app.outbound_ip_addresses
}

output "mysql_fqdn" {
  value = module.mysql.server_fqdn
}

output "mysql_server_name" {
  value = module.mysql.server_name
}

output "subscription_id" {
  value = var.subscription_id
}

output "mysql_database_name" {
  value = module.mysql.database_name
}