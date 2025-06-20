variable "instance_name" {
  description = "Name of the flexible server instance"
  type        = string
  default     = null
}

variable "pg_version" {
  description = "The PostgreSQL version"
  type        = string
  default     = "16"
}

variable "pg_admin_username" {
  description = "The admin username of the PostgreSQL instance"
  type        = string
  default     = "postgres"
}

variable "pg_sku_name" {
  description = "The SKU name for the PostgreSQL instance"
  type        = string
  default     = "GP_Standard_D4ds_v5"
}

variable "pg_storage_mb" {
  description = "The storage size in MB for the PostgreSQL instance"
  type        = number
  default     = 32768

  validation {
    condition     = contains([32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553409], var.pg_storage_mb)
    error_message = "Must be a valid value - 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216 or 33553408"
  }
}

variable "pg_subnet_cidr" {
  description = "CIDR of postgres subnet in the VPC"
  type        = string
  default     = "10.192.6.0/23"
}

variable "db_name" {
  description = "Name of the Bufstream database for metadata store"
  type        = string
  default     = "bufstream"
}

variable "db_collation" {
  description = "Collation for the PostgreSQL database"
  type        = string
  default     = "en_US.utf8"
}

variable "resource_group" {
  description = "The resource group the flexible server should be created under"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC where the flexible server should be deployed"
  type        = string
}

variable "location" {
  description = "The region where the flexible server should be deployed"
  type        = string
}
