variable "resource_group_name" {
  description = "Name of new Resource Group to create."
  type        = string
}

variable "location" {
  description = "Where to deploy the resources."
  type        = string
}

variable "storage_account_create" {
  description = "Whether to create a new storage account."
  type        = string
  default     = true
}

variable "storage_account_name" {
  description = "Name of the storage account."
  type        = string
}

variable "storage_container_create" {
  description = "Whether to create the storage account."
  type        = bool
  default     = true
}

variable "storage_container_name" {
  description = "Name of the storage container."
  type        = string
}

variable "storage_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}

variable "storage_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "RAGRS"
}

variable "storage_large_file_share_enabled" {
  description = "Large file share enabled"
  type        = bool
  default     = false
}

variable "storage_grant_permissions" {
  description = "Grant necessary permissions on the storage account for the bufstream identity."
  type        = string
  default     = true
}

variable "bufstream_identity" {
  description = "Bufstream Identity."
  type        = string
}
