variable "instance_name" {
  description = "Name of the CloudSQL instance"
  type        = string
  default     = null
}

variable "database_version" {
  description = "The database version for the CloudSQL instance - must be POSTGRES"
  type        = string
  default     = "POSTGRES_17"

  validation {
    condition     = startswith(var.database_version, "POSTGRES_")
    error_message = "Database version must be a Postgres version"
  }
}

variable "region" {
  type = string
}

variable "cloudsql_tier" {
  description = "Tier for the database instance"
  type        = string
  default     = "db-custom-4-8192"
}

variable "cloudsql_disk_size" {
  description = "Disk size in GB for the database instance"
  type        = number
  default     = 100
}

variable "cloudsql_availability_type" {
  description = "Availability type of the database instance - must be 'REGIONAL' or 'ZONAL'"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.cloudsql_availability_type)
    error_message = "Availability type must be 'REGIONAL' or 'ZONAL'"
  }
}

variable "cloudsql_edition" {
  description = "The edition of the database instance - must be 'ENTERPRISE' or 'ENTERPRISE_PLUS'"
  type        = string
  default     = "ENTERPRISE"

  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.cloudsql_edition)
    error_message = "Edition must be 'ENTERPRISE' or 'ENTERPRISE_PLUS'"
  }
}

variable "vpc_id" {
  description = "ID of VPC to use for database instance"
  type        = string
}

variable "project_id" {
  description = "The project id where the CloudSQL instance is provisioned"
  type        = string
}

variable "service_account" {
  description = "The service account to use for authentication for the Postgres database"
  type        = string
}

variable "database_name" {
  description = "The database name for the Bufstream metadata store"
  type        = string
  default     = "bufstream"
}
