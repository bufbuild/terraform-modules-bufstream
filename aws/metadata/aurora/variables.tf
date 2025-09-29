variable "vpc_id" {
  description = "VPC ID of the EKS cluster"
  type        = string
}

variable "cluster_instance_count" {
  description = "number of instances of rds to provision"
  type        = number
  default     = 2
}

variable "aws_region" {
  description = "region to provision resources"
  type        = string
}

variable "postgres_username" {
  description = "Postgres username for aurora instance"
  type        = string
  default     = "postgres"
}

variable "subnet_ids" {
  description = "IDs of the private subnets for the aurora instance to use"
  type        = list(string)
}

variable "aurora_port" {
  description = "Port number for the aurora instance"
  type        = number
  default     = 5432
}

variable "aurora_instance_class" {
  description = "aurora instance class to use"
  type        = string
  default     = "db.r8g.xlarge"
}

variable "postgres_version" {
  description = "Postgres version"
  type        = string
  default     = "17"
}

variable "postgres_db_name" {
  description = "Name of the database for metadata"
  type        = string
  default     = "bufstream"
}

variable "aurora_identifier" {
  description = "Identifier of the aurora instance"
  type        = string
}

variable "availability_zone" {
  type    = string
  default = null
}
