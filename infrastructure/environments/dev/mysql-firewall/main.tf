resource "azurerm_mysql_flexible_server_firewall_rule" "container_app_egress" {
  for_each = var.container_app_egress_ips

  name                = "aca-${replace(each.value, ".", "-")}"
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  start_ip_address    = each.value
  end_ip_address      = each.value
}
