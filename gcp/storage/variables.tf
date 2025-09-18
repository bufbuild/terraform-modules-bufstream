variable "project_id" {
  description = "Project to create the VPC in."
  type        = string
}

variable "region" {
  description = "Region to put resources in."
  type        = string
}

variable "bucket_create" {
  description = "Whether to create a new GCS bucket."
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Name of GCS bucket to create or use."
  type        = string
}

variable "bucket_grant_permissions" {
  description = "Grant necessary permissions on the bucket for the bufstream service account."
  type        = string
  default     = true
}

variable "create_custom_iam_role" {
  description = "Whether to create and use a custom GCP IAM role with minimal GCS permissions."
  type        = bool
  default     = true
}

variable "bufstream_service_account" {
  description = "Bufstream Service Account Email."
  type        = string
}

variable "custom_iam_role_id" {
  description = "Identifier to separate roles created in the same project. Prevents deletion collision"
  type = string
}
