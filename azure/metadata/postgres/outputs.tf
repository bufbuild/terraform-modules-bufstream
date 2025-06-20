output "pg_endpoint" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "db_username" {
  value = azurerm_postgresql_flexible_server.postgres.administrator_login
}

output "db_name" {
  value = azurerm_postgresql_flexible_server_database.bufstream.name
}

output "server_name" {
  value = azurerm_postgresql_flexible_server.postgres.name
}
