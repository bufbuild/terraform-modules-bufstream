locals {
  storage_account_ref   = var.storage_account_create ? azurerm_storage_account.bufstream[0] : data.azurerm_storage_account.bufstream[0]
  storage_container_ref = var.storage_container_create ? azurerm_storage_container.bufstream[0] : data.azurerm_storage_container.bufstream[0]
}

resource "azurerm_storage_account" "bufstream" {
  count = var.storage_account_create ? 1 : 0

  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = var.storage_kind
  account_tier             = var.storage_tier
  account_replication_type = var.storage_replication_type
  large_file_share_enabled = var.storage_large_file_share_enabled

  allow_nested_items_to_be_public = false
}

data "azurerm_storage_account" "bufstream" {
  count = var.storage_account_create ? 0 : 1

  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_container" "bufstream" {
  count = var.storage_container_create ? 1 : 0

  name               = var.storage_container_name
  storage_account_id = local.storage_account_ref.id
}

data "azurerm_storage_container" "bufstream" {
  count = var.storage_container_create ? 0 : 1

  name               = var.storage_container_name
  storage_account_id = local.storage_account_ref.id
}

resource "azurerm_role_assignment" "bufstream" {
  count = var.storage_grant_permissions ? 1 : 0

  scope                = local.storage_container_ref.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.bufstream_identity
}
