variable "create_bucket" {
  description = "Create an s3 bucket for use."
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Name of bucket, must be globally unique"
  type        = string
}

variable "bufstream_role" {
  description = "Name of the IRSA role for bufstream."
  type        = string
}

variable "force_destroy" {
  description = "Set force destroy on the bucket."
  type        = string
  default     = false
}
