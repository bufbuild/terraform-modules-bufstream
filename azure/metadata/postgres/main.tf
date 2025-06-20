locals {
  instance_name = var.instance_name != null ? var.instance_name : random_string.instance_name.result
}

resource "random_string" "instance_name" {
  length  = 16
  special = false
  numeric = false
  upper   = false
}

data "azurerm_virtual_network" "buf" {
  name                = var.vpc_name
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "postgres" {
  name                 = "${local.instance_name}-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = data.azurerm_virtual_network.buf.name
  address_prefixes     = [var.pg_subnet_cidr]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "buf" {
  name                = "${local.instance_name}-pdz.postgres.database.azure.com"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "buf" {
  name                  = "${local.instance_name}-VnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.buf.name
  virtual_network_id    = data.azurerm_virtual_network.buf.id
  resource_group_name   = var.resource_group

  depends_on = [azurerm_subnet.postgres]
}

resource "random_password" "temp_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = local.instance_name
  resource_group_name    = var.resource_group
  location               = var.location
  version                = var.pg_version
  administrator_login    = var.pg_admin_username
  administrator_password = random_password.temp_password.result
  sku_name               = var.pg_sku_name
  storage_mb             = var.pg_storage_mb
  auto_grow_enabled      = true
  zone                   = "1"

  public_network_access_enabled = false
  private_dns_zone_id           = azurerm_private_dns_zone.buf.id
  delegated_subnet_id           = azurerm_subnet.postgres.id

  high_availability {
    mode = "ZoneRedundant"
  }

  authentication {
    password_auth_enabled = true
  }

  lifecycle {
    ignore_changes = [
      high_availability[0].standby_availability_zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "bufstream" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = var.db_collation
}
