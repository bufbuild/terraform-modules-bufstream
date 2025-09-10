variable "vpc_id" {
  description = "VPC ID of the EKS cluster"
  type        = string
}

variable "postgres_username" {
  description = "Postgres username for RDS instance"
  type        = string
  default     = "postgres"
}

variable "subnet_ids" {
  description = "IDs of the private subnets for the RDS instance to use"
  type        = list(string)
}

variable "rds_port" {
  description = "Port number for the RDS instance"
  type        = number
  default     = 5432
}

# Default values from
# https://buf.build/docs/bufstream/deployment/aws/deploy-postgres/#create-an-rds-for-postgresql-instance
variable "rds_instance_class" {
  description = "RDS instance class to use"
  type        = string
  default     = "db.c6gd.xlarge"
}

variable "postgres_version" {
  description = "Postgres version"
  type        = string
  default     = "17"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS"
  type        = number
  default     = 20
}

variable "postgres_db_name" {
  description = "Name of the database for metadata"
  type        = string
  default     = "bufstream"
}

variable "rds_identifier" {
  description = "Identifier of the RDS instance"
  type        = string
}
